// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0
import "../../js/hackertyper.js" as JS

Rectangle {
    id: root
    width: 854
    height: 480
    onRotationChanged: {
        width = parent.width
        console.log("width = " + width)
    }

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
                property int speed: 14
                property int codePos: 0
                property bool textUpdate: false
                Keys.onPressed: {
                    JS.getNextBlock();
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

    AboutButton {
        id: aboutButton
    }
}

PseudoKeyboard {
    id: pseudoKbd
    opacity: 0
    y: base.height
    height: 0
    anchors.bottom: parent.bottom
}

function updateFlickArea()
{
    if (!flickArea.atYEnd)
        flickArea.contentY = textEdit.height - flickArea.height + 3;
}

}
