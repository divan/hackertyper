// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: button
    width: 65
    height: 65
    color: '#222222'
    radius: 8
    border.color: "darkgreen"
    border.width: 1
    property string value: ""
    Text {
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
            getNextBlock();
        }
        onReleased: {
            parent.state = '';
        }
    }
    states: [
        State {
            name: 'PRESSED'
            PropertyChanges { target: button; color: "white" }
        }
    ]
}
