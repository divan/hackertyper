// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: hackButton
    width: 256
    height: 64
    radius: 1
    border.color: "lime"
    border.width: 1
    color: "black"

    Text {
        id: text
        text: "Hack!"
        font.pixelSize: 40
        font.bold: true
        color: "lime"
        anchors.centerIn: parent
    }
    MouseArea {
        anchors.fill: parent

    onClicked: {
        applicationData.speed = speedSlider.value;
        codeData.pos = 0;
        textEdit.text = "";
        settingsWindow.state = "";
    }
        onPressed: {
            parent.state = 'PRESSED';
        }
        onReleased: {
            parent.state = '';
        }
    }
    states: [
        State {
            name: 'PRESSED'
            PropertyChanges {
                target: hackButton;
                border.color: "white";
            }
        }
    ]
}
