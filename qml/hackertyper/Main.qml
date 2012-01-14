// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: root
    width: 854
    height: 480
    property int counterGranted: 0
    property int counterDenied: 0

    Rectangle {
        id: base
        width: parent.width
        height: parent.height - pseudoKbd.height - 2
        color: "black"
        Flickable {
            id: flickArea
            anchors.fill: base
            height: base.height
            contentWidth: textEdit.width
            contentHeight: textEdit.height
            flickableDirection: Flickable.VerticalFlick
            clip: true
            onHeightChanged: {
                updateFlickArea();
            }

            TextEdit {
                id: textEdit
                anchors.bottom: parent.bottom
                width: base.width
                text: ""
                readOnly: true
                font.family: "monospace"
                font.pointSize: 18
                color: "#00FF00"
                focus: true
                wrapMode: TextEdit.WrapAnywhere
                textFormat: TextEdit.PlainText
            }
        }
        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                if (pseudoKbd.state == "show")
                    pseudoKbd.state = "";
                else
                    pseudoKbd.state = "show";
            }
        }

        SettingsButton {
            id: settingsButton
            onClicked: settingsWindow.state = "show";
        }
    }

    AccessMessage {
        id: accessGrantedMsg
        msgText: "Access Granted"
        msgColor: "green"
    }
    AccessMessage {
        id: accessDeniedMsg
        msgText: "Access Denied"
        msgColor: "red"
    }

    PseudoKeyboard {
        id: pseudoKbd
    }

    SettingsWindow {
        id: settingsWindow
        anchors.fill: parent
    }

    states: [
        State {
            name: "NORMAL"
            PropertyChanges { target: accessGrantedMsg; state: ""; }
            PropertyChanges { target: accessDeniedMsg; state: ""; }
        },
        State {
            name: "ACCESS_GRANTED"
            PropertyChanges { target: accessGrantedMsg; state: "show"; }
            PropertyChanges { target: accessDeniedMsg; state: ""; }
        },
        State {
            name: "ACCESS_DENIED"
            PropertyChanges { target: accessGrantedMsg; state: ""; }
            PropertyChanges { target: accessDeniedMsg; state: "show"; }
        }
    ]

    function updateFlickArea()
    {
        if (!flickArea.atYEnd)
            flickArea.contentY = textEdit.height - flickArea.height + 3;
    }
}
