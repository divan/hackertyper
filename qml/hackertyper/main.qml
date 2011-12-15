import QtQuick 1.0

Rectangle {
    id: base
    width: 800
    height: 480
    color: "black"
    Flickable {
        id: flickArea
        anchors.fill: base
        contentWidth: textEdit.width
        contentHeight: textEdit.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        TextEdit {
            id: textEdit
            anchors.bottom: parent.bottom
            width: base.width
            text: ""
            readOnly: false
            font.family: "monospace"
            font.pointSize: 18
            color: "#00FF00"
            focus: true
            wrapMode: TextEdit.WrapAnywhere
            textFormat: TextEdit.PlainText
            property int speed: 4
            property int codePos: 0
            property bool textUpdate: false

            onTextChanged: {
                if (textEdit.textUpdate == true)
                {
                    return;
                }

                if (textEdit.text.charAt(0) == "?")
                {
                    accessGrantedMsg.visible = true;
                } else if (textEdit.text.charAt(0) == "@")
                {
                    accessDeniedMsg.visible = true;
                } else if (accessGrantedMsg.visible == true || accessDeniedMsg.visible == true)
                {
                    accessGrantedMsg.visible = false;
                    accessDeniedMsg.visible = false;
                }

                textEdit.textUpdate = true;
                getNextBlock();
                textEdit.textUpdate = false;
            }
        }
     }
     Rectangle {
         id: accessGrantedMsg
         width: base.width * 0.8
         height: width * 0.2
         x: base.width/2 - width/2
         y: base.height/2 - height/2
         visible: false
         color: "gray"
         border.color: "lightgrey"
         border.width: 1
         Text {
             anchors.fill: accessGrantedMsg
             text: "Access Granted"
             font.family: "monospace"
             font.pointSize: 48
             font.bold: true
             color: "lightgreen"
             verticalAlignment: Text.AlignVCenter
             horizontalAlignment: Text.AlignHCenter
         }
     }
     Rectangle {
         id: accessDeniedMsg
         width: base.width * 0.8
         height: width * 0.2
         x: base.width/2 - width/2
         y: base.height/2 - height/2
         visible: false
         color: "darkgrey"
         border.color: "red"
         border.width: 1
         Text {
             anchors.fill: accessDeniedMsg
             text: "Access Denied"
             font.family: "monospace"
             font.pointSize: 48
             font.bold: true
             color: "red"
             verticalAlignment: Text.AlignVCenter
             horizontalAlignment: Text.AlignHCenter
         }
     }

     function getNextBlock()
     {
var code = "struct group_info init_groups = { .usage = ATOMIC_INIT(2) };\n\
\n\
struct group_info *groups_alloc(int gidsetsize){\n\
\n\
        struct group_info *group_info;\n\
\n\
        int nblocks;\n\
\n\
        int i;\n\
\n\
\n\
\n\
        nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;\n\
\n\
        /* Make sure we always allocate at least one indirect block pointer */\n\
\n\
        nblocks = nblocks ? : 1;\n\
\n\
        group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *), GFP_USER);\n\
\n\
        if (!group_info)\n\
\n\
                return NULL;\n\
\n\
        group_info->ngroups = gidsetsize;\n\
\n\
        group_info->nblocks = nblocks;\n\
\n\
        atomic_set(&group_info->usage, 1);\n\
\n\
\n\
\n\
        if (gidsetsize <= NGROUPS_SMALL)\n\
\n\
                group_info->blocks[0] = group_info->small_block;\n\
\n\
        else {\n\
\n\
                for (i = 0; i < nblocks; i++) {\n\
\n\
                        gid_t *b;\n\
\n\
                        b = (void *)__get_free_page(GFP_USER);\n\
\n\
                        if (!b)\n\
\n\
                                goto out_undo_partial_alloc;\n\
\n\
                        group_info->blocks[i] = b;\n\
\n\
                }\n\
\n\
        }\n\
\n\
        return group_info;\n\
\n\
\n\
\n\
out_undo_partial_alloc:\n\
\n\
        while (--i >= 0) {\n\
\n\
                free_page((unsigned long)group_info->blocks[i]);\n\
\n\
        }\n\
\n\
        kfree(group_info);\n\
\n\
        return NULL;\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(groups_alloc);\n\
\n\
\n\
\n\
void groups_free(struct group_info *group_info)\n\
\n\
{\n\
\n\
        if (group_info->blocks[0] != group_info->small_block) {\n\
\n\
                int i;\n\
\n\
                for (i = 0; i < group_info->nblocks; i++)\n\
\n\
                        free_page((unsigned long)group_info->blocks[i]);\n\
\n\
        }\n\
\n\
        kfree(group_info);\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(groups_free);\n\
\n\
\n\
\n\
/* export the group_info to a user-space array */\n\
\n\
static int groups_to_user(gid_t __user *grouplist,\n\
\n\
                          const struct group_info *group_info)\n\
\n\
{\n\
\n\
        int i;\n\
\n\
        unsigned int count = group_info->ngroups;\n\
\n\
\n\
\n\
        for (i = 0; i < group_info->nblocks; i++) {\n\
\n\
                unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);\n\
\n\
                unsigned int len = cp_count * sizeof(*grouplist);\n\
\n\
\n\
\n\
                if (copy_to_user(grouplist, group_info->blocks[i], len))\n\
\n\
                        return -EFAULT;\n\
\n\
\n\
\n\
                grouplist += NGROUPS_PER_BLOCK;\n\
\n\
                count -= cp_count;\n\
\n\
        }\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
/* fill a group_info from a user-space array - it must be allocated already */\n\
\n\
static int groups_from_user(struct group_info *group_info,\n\
\n\
    gid_t __user *grouplist)\n\
\n\
{\n\
\n\
        int i;\n\
\n\
        unsigned int count = group_info->ngroups;\n\
\n\
\n\
\n\
        for (i = 0; i < group_info->nblocks; i++) {\n\
\n\
                unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);\n\
\n\
                unsigned int len = cp_count * sizeof(*grouplist);\n\
\n\
\n\
\n\
                if (copy_from_user(group_info->blocks[i], grouplist, len))\n\
\n\
                        return -EFAULT;\n\
\n\
\n\
\n\
                grouplist += NGROUPS_PER_BLOCK;\n\
\n\
                count -= cp_count;\n\
\n\
        }\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
/* a simple Shell sort */\n\
\n\
static void groups_sort(struct group_info *group_info)\n\
\n\
{\n\
\n\
        int base, max, stride;\n\
\n\
        int gidsetsize = group_info->ngroups;\n\
\n\
\n\
\n\
        for (stride = 1; stride < gidsetsize; stride = 3 * stride + 1)\n\
\n\
                ; /* nothing */\n\
\n\
        stride /= 3;\n\
\n\
\n\
\n\
        while (stride) {\n\
\n\
                max = gidsetsize - stride;\n\
\n\
                for (base = 0; base < max; base++) {\n\
\n\
                        int left = base;\n\
\n\
                        int right = left + stride;\n\
\n\
                        gid_t tmp = GROUP_AT(group_info, right);\n\
\n\
\n\
\n\
                        while (left >= 0 && GROUP_AT(group_info, left) > tmp) {\n\
\n\
                                GROUP_AT(group_info, right) =\n\
\n\
                                    GROUP_AT(group_info, left);\n\
\n\
                                right = left;\n\
\n\
                                left -= stride;\n\
\n\
                        }\n\
\n\
                        GROUP_AT(group_info, right) = tmp;\n\
\n\
                }\n\
\n\
                stride /= 3;\n\
\n\
        }\n\
\n\
}\n\
\n\
\n\
\n\
/* a simple bsearch */\n\
\n\
int groups_search(const struct group_info *group_info, gid_t grp)\n\
\n\
{\n\
\n\
        unsigned int left, right;\n\
\n\
\n\
\n\
        if (!group_info)\n\
\n\
                return 0;\n\
\n\
\n\
\n\
        left = 0;\n\
\n\
        right = group_info->ngroups;\n\
\n\
        while (left < right) {\n\
\n\
                unsigned int mid = (left+right)/2;\n\
\n\
                if (grp > GROUP_AT(group_info, mid))\n\
\n\
                        left = mid + 1;\n\
\n\
                else if (grp < GROUP_AT(group_info, mid))\n\
\n\
                        right = mid;\n\
\n\
                else\n\
\n\
                        return 1;\n\
\n\
        }\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
/**\n\
\n\
 * set_groups - Change a group subscription in a set of credentials\n\
\n\
 * @new: The newly prepared set of credentials to alter\n\
\n\
 * @group_info: The group list to install\n\
\n\
 *\n\
\n\
 * Validate a group subscription and, if valid, insert it into a set\n\
\n\
 * of credentials.\n\
\n\
 */\n\
\n\
int set_groups(struct cred *new, struct group_info *group_info)\n\
\n\
{\n\
\n\
        put_group_info(new->group_info);\n\
\n\
        groups_sort(group_info);\n\
\n\
        get_group_info(group_info);\n\
\n\
        new->group_info = group_info;\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(set_groups);\n\
\n\
\n\
\n\
/**\n\
\n\
 * set_current_groups - Change current's group subscription\n\
\n\
 * @group_info: The group list to impose\n\
\n\
 *\n\
\n\
 * Validate a group subscription and, if valid, impose it upon current's task\n\
\n\
 * security record.\n\
\n\
 */\n\
\n\
int set_current_groups(struct group_info *group_info)\n\
\n\
{\n\
\n\
        struct cred *new;\n\
\n\
        int ret;\n\
\n\
\n\
\n\
        new = prepare_creds();\n\
\n\
        if (!new)\n\
\n\
                return -ENOMEM;\n\
\n\
\n\
\n\
        ret = set_groups(new, group_info);\n\
\n\
        if (ret < 0) {\n\
\n\
                abort_creds(new);\n\
\n\
                return ret;\n\
\n\
        }\n\
\n\
\n\
\n\
        return commit_creds(new);\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(set_current_groups);\n\
\n\
\n\
\n\
SYSCALL_DEFINE2(getgroups, int, gidsetsize, gid_t __user *, grouplist)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int i;\n\
\n\
\n\
\n\
        if (gidsetsize < 0)\n\
\n\
                return -EINVAL;\n\
\n\
\n\
\n\
        /* no need to grab task_lock here; it cannot change */\n\
\n\
        i = cred->group_info->ngroups;\n\
\n\
        if (gidsetsize) {\n\
\n\
                if (i > gidsetsize) {\n\
\n\
                        i = -EINVAL;\n\
\n\
                        goto out;\n\
\n\
                }\n\
\n\
                if (groups_to_user(grouplist, cred->group_info)) {\n\
\n\
                        i = -EFAULT;\n\
\n\
                        goto out;\n\
\n\
                }\n\
\n\
        }\n\
\n\
out:\n\
\n\
        return i;\n\
\n\
}\n\
\n\
\n\
\n\
/*\n\
\n\
 *	SMP: Our groups are copy-on-write. We can set them safely\n\
\n\
 *	without another task interfering.\n\
\n\
 */\n\
\n\
\n\
\n\
SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)\n\
\n\
{\n\
\n\
        struct group_info *group_info;\n\
\n\
        int retval;\n\
\n\
\n\
\n\
        if (!nsown_capable(CAP_SETGID))\n\
\n\
                return -EPERM;\n\
\n\
        if ((unsigned)gidsetsize > NGROUPS_MAX)\n\
\n\
                return -EINVAL;\n\
\n\
\n\
\n\
        group_info = groups_alloc(gidsetsize);\n\
\n\
        if (!group_info)\n\
\n\
                return -ENOMEM;\n\
\n\
        retval = groups_from_user(group_info, grouplist);\n\
\n\
        if (retval) {\n\
\n\
                put_group_info(group_info);\n\
\n\
                return retval;\n\
\n\
        }\n\
\n\
\n\
\n\
        retval = set_current_groups(group_info);\n\
\n\
        put_group_info(group_info);\n\
\n\
\n\
\n\
        return retval;\n\
\n\
}\n\
\n\
\n\
\n\
/*\n\
\n\
 * Check whether we're fsgid/egid or in the supplemental group..\n\
\n\
 */\n\
\n\
int in_group_p(gid_t grp)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int retval = 1;\n\
\n\
\n\
\n\
        if (grp != cred->fsgid)\n\
\n\
                retval = groups_search(cred->group_info, grp);\n\
\n\
        return retval;\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(in_group_p);\n\
\n\
\n\
\n\
int in_egroup_p(gid_t grp)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int retval = 1;\n\
\n\
\n\
\n\
        if (grp != cred->egid)\n\
\n\
                retval = groups_search(cred->group_info, grp);\n\
\n\
        return retval;\n\
\n\
}";
         var out = code.substr(0, textEdit.codePos+textEdit.speed);
         textEdit.codePos += textEdit.speed;
         textEdit.text = out;
         if (!flickArea.atYEnd)
             flickArea.contentY = textEdit.height - flickArea.height;
     }
}
