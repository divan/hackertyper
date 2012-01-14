// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: button
    width: keyWidth
    height: 65
    color: '#222222'
    radius: 8
    border.color: "darkgreen"
    border.width: 1
    property string value: ""
    property int keyWidth: 65
    Text {
        id: keyText
        text: value
        font.pixelSize: 30
        font.bold: true
        color: "green"
        anchors.centerIn: parent
    }
    MouseArea {
        anchors.fill: parent
        onPressed: {
            parent.state = 'PRESSED';
            textEdit.text += codeData.getNextCode(applicationData.speed);
            updateFlickArea();
        }
        onReleased: {
            parent.state = '';
        }
    }
    states: [
        State {
            name: 'PRESSED'
            PropertyChanges {
                target: button;
                border.color: "white";
                color: "#777777";
            }
        }
    ]
}
