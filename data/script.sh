#! /bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
DEVICE=/dev/vboxdrv
LOG="/var/log/vbox-install.log"
NOLSB=
DEBIAN=yes
MODPROBE=/sbin/modprobe

if [ -n "$NOLSB" ]; then
    if [ -f /etc/redhat-release ]; then
        system=redhat
    elif [ -f /etc/SuSE-release ]; then
        system=suse
    elif [ -f /etc/gentoo-release ]; then
        system=gentoo
    fi
fi

[ -r /etc/default/virtualbox ] && . /etc/default/virtualbox

if [ -z "$NOLSB" ]; then
    . /lib/lsb/init-functions
    fail_msg() {
        echo ""
        log_failure_msg "$1"
    }
    succ_msg() {
        log_end_msg 0
    }
    begin_msg() {
        log_daemon_msg "$@"
    }
else
    if [ "$system" = "redhat" ]; then
        . /etc/init.d/functions
        fail_msg() {
            echo -n " "
            echo_failure
            echo
            echo "  ($1)"
        }
        succ_msg() {
            echo -n " "
            echo_success
            echo
        }
    elif [ "$system" = "suse" ]; then
        . /etc/rc.status
        fail_msg() {
            rc_failed 1
            rc_status -v
            echo "  ($1)"
        }
        succ_msg() {
            rc_reset
            rc_status -v
        }
    elif [ "$system" = "gentoo" ]; then
        if [ -f /sbin/functions.sh ]; then
            . /sbin/functions.sh
        elif [ -f /etc/init.d/functions.sh ]; then
            . /etc/init.d/functions.sh
        fi
        fail_msg() {
            eerror "$1"
        }
        succ_msg() {
            eend "$?"
        }
        begin_msg() {
            ebegin "$1"
        }
        if [ "`which $0`" = "/sbin/rc" ]; then
            shift
        fi
    else
        fail_msg() {
            echo " ...failed!"
            echo "  ($1)"
        }
        succ_msg() {
            echo " ...done."
        }
    fi
    if [ "$system" != "gentoo" ]; then
        begin_msg() {
            [ -z "${1:-}" ] && return 1
            if [ -z "${2:-}" ]; then
                echo -n "$1"
            else
                echo -n "$1: $2"
            fi
        }
    fi
fi

failure()
{
    fail_msg "$1"
    exit 0
}

running()
{
    lsmod | grep -q "$1[^_-]"
}

start()
{
    begin_msg "Starting VirtualBox kernel modules"
    if [ -d /proc/xen ]; then
        failure "Running VirtualBox in a Xen environment is not supported"
    fi
    if ! running vboxdrv; then
        if ! rm -f $DEVICE; then
            failure "Cannot remove $DEVICE"
        fi
        if ! $MODPROBE vboxdrv > /dev/null 2>&1; then
            failure "modprobe vboxdrv failed. Please use 'dmesg' to find out why"
        fi
        sleep .2
    fi
    # ensure the character special exists
    if [ ! -c $DEVICE ]; then
        MAJOR=`sed -n 's;\([0-9]\+\) vboxdrv;\1;p' /proc/devices`
        if [ ! -z "$MAJOR" ]; then
            MINOR=0
        else
            MINOR=`sed -n 's;\([0-9]\+\) vboxdrv;\1;p' /proc/misc`
            if [ ! -z "$MINOR" ]; then
                MAJOR=10
            fi
        fi
        if [ -z "$MAJOR" ]; then
            rmmod vboxdrv 2>/dev/null
            failure "Cannot locate the VirtualBox device"
        fi
        if ! mknod -m 0660 $DEVICE c $MAJOR $MINOR 2>/dev/null; then
            rmmod vboxdrv 2>/dev/null
            failure "Cannot create device $DEVICE with major $MAJOR and minor $MINOR"
        fi
    fi
    # ensure permissions
    if ! chown :root $DEVICE 2>/dev/null; then
        rmmod vboxnetadp 2>/dev/null
        rmmod vboxnetflt 2>/dev/null
        rmmod vboxdrv 2>/dev/null
        failure "Cannot change group root for device $DEVICE"
    fi
    if ! $MODPROBE vboxnetflt > /dev/null 2>&1; then
        failure "modprobe vboxnetflt failed. Please use 'dmesg' to find out why"
    fi
    if ! $MODPROBE vboxnetadp > /dev/null 2>&1; then
        failure "modprobe vboxnetadp failed. Please use 'dmesg' to find out why"
    fi
    # Create the /dev/vboxusb directory if the host supports that method
    # of USB access.  The USB code checks for the existance of that path.
    if grep -q usb_device /proc/devices; then
        mkdir -p -m 0750 /dev/vboxusb 2>/dev/null
        chown root:vboxusers /dev/vboxusb 2>/dev/null
    fi
    succ_msg
}

stop()
{
    begin_msg "Stopping VirtualBox kernel modules"
    if running vboxnetadp; then
        if ! rmmod vboxnetadp 2>/dev/null; then
            failure "Cannot unload module vboxnetadp"
        fi
    fi
    if running vboxdrv; then
        if running vboxnetflt; then
            if ! rmmod vboxnetflt 2>/dev/null; then
                failure "Cannot unload module vboxnetflt"
            fi
        fi
        if ! rmmod vboxdrv 2>/dev/null; then
            failure "Cannot unload module vboxdrv"
        fi
        if ! rm -f $DEVICE; then
            failure "Cannot unlink $DEVICE"
        fi
    fi
    succ_msg
}

# enter the following variables in /etc/default/virtualbox:
#   SHUTDOWN_USERS="foo bar"  
#     check for running VMs of user foo and user bar
#   SHUTDOWN=poweroff
#   SHUTDOWN=acpibutton
#   SHUTDOWN=savestate
#     select one of these shutdown methods for running VMs
stop_vms()
{
    wait=0
    for i in $SHUTDOWN_USERS; do
        # don't create the ipcd directory with wrong permissions!
        if [ -d /tmp/.vbox-$i-ipc ]; then
            export VBOX_IPC_SOCKETID="$i"
            VMS=`$VBOXMANAGE --nologo list runningvms | sed -e 's/^".*".*{\(.*\)}/\1/' 2>/dev/null`
            if [ -n "$VMS" ]; then
                if [ "$SHUTDOWN" = "poweroff" ]; then
                    begin_msg "Powering off remaining VMs"
                    for v in $VMS; do
                        $VBOXMANAGE --nologo controlvm $v poweroff
                    done
                    succ_msg
                elif [ "$SHUTDOWN" = "acpibutton" ]; then
                    begin_msg "Sending ACPI power button event to remaining VMs"
                    for v in $VMS; do
                        $VBOXMANAGE --nologo controlvm $v acpipowerbutton
                        wait=30
                    done
                    succ_msg
                elif [ "$SHUTDOWN" = "savestate" ]; then
                    begin_msg "Saving state of remaining VMs"
                    for v in $VMS; do
                        $VBOXMANAGE --nologo controlvm $v savestate
                    done
                    succ_msg
                fi
            fi
        fi
    done
    # wait for some seconds when doing ACPI shutdown
    if [ "$wait" -ne 0 ]; then
        begin_msg "Waiting for $wait seconds for VM shutdown"
        sleep $wait
        succ_msg
    fi
}

# setup_script
setup()
{
    stop
    begin_msg "Uninstalling old VirtualBox DKMS kernel modules"
    $DODKMS uninstall > $LOG
    succ_msg
    if find /lib/modules/`uname -r` -name "vboxnetadp\.*" 2>/dev/null|grep -q vboxnetadp; then
        begin_msg "Removing old VirtualBox netadp kernel module"
        find /lib/modules/`uname -r` -name "vboxnetadp\.*" 2>/dev/null|xargs rm -f 2>/dev/null
        succ_msg
    fi  
    if find /lib/modules/`uname -r` -name "vboxnetflt\.*" 2>/dev/null|grep -q vboxnetflt; then
        begin_msg "Removing old VirtualBox netflt kernel module"
        find /lib/modules/`uname -r` -name "vboxnetflt\.*" 2>/dev/null|xargs rm -f 2>/dev/null
        succ_msg
    fi  
    if find /lib/modules/`uname -r` -name "vboxdrv\.*" 2>/dev/null|grep -q vboxdrv; then
        begin_msg "Removing old VirtualBox kernel module"
        find /lib/modules/`uname -r` -name "vboxdrv\.*" 2>/dev/null|xargs rm -f 2>/dev/null
        succ_msg
    fi
    begin_msg "Trying to register the VirtualBox kernel modules using DKMS"
    if ! $DODKMS install >> $LOG; then
      fail_msg "Failed, trying without DKMS"
      begin_msg "Recompiling VirtualBox kernel modules"
      if ! $BUILDVBOXDRV \
          --save-module-symvers /tmp/vboxdrv-Module.symvers \
          --no-print-directory install >> $LOG 2>&1; then
          failure "Look at $LOG to find out what went wrong"
      fi
      if ! $BUILDVBOXNETFLT \
          --use-module-symvers /tmp/vboxdrv-Module.symvers \
          --no-print-directory install >> $LOG 2>&1; then
          failure "Look at $LOG to find out what went wrong"
      fi
      if ! $BUILDVBOXNETADP \
          --use-module-symvers /tmp/vboxdrv-Module.symvers \
          --no-print-directory install >> $LOG 2>&1; then
          failure "Look at $LOG to find out what went wrong"
      fi
    fi
    rm -f /etc/vbox/module_not_compiled
    succ_msg
    start
}

dmnstatus()
{
    if running vboxdrv; then
        if running vboxnetflt; then
            if running vboxnetadp; then
                echo "VirtualBox kernel modules (vboxdrv, vboxnetflt and vboxnetadp) are loaded."
            else
                echo "VirtualBox kernel modules (vboxdrv and vboxnetflt) are loaded."
            fi
        else
            echo "VirtualBox kernel module is loaded."
        fi
        for i in $SHUTDOWN_USERS; do
            # don't create the ipcd directory with wrong permissions!
            if [ -d /tmp/.vbox-$i-ipc ]; then
                export VBOX_IPC_SOCKETID="$i"
                VMS=`$VBOXMANAGE --nologo list runningvms | sed -e 's/^".*".*{\(.*\)}/\1/' 2>/dev/null`
                if [ -n "$VMS" ]; then
                    echo "The following VMs are currently running:"
                    for v in $VMS; do
                       echo "  $v"
                    done
                fi
            fi
        done
    else
        echo "VirtualBox kernel module is not loaded."
    fi
}

case "$1" in
start)
    start
    ;;
stop)
    stop_vms
    stop
    ;;
stop_vms)
    stop_vms
    ;;
restart)
    stop && start
    ;;
force-reload)
    stop
    start
    ;;
setup)
    setup
    ;;
status)
    dmnstatus
    ;;
*)
    echo "Usage: $0 {start|stop|stop_vms|restart|force-reload|status|setup}"
    exit 1
esac

exit 0
