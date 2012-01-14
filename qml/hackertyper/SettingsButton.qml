// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: settingsButton
    width: 50
    height: 50
    anchors.top: parent.top
    anchors.right: parent.right
    color: '#222222'
    opacity: 0.5
    radius: 25
    Text {
        text: "?"
        font.pixelSize: 30
        color: '#444444'
        anchors.centerIn: parent
    }
    signal clicked()
    MouseArea {
        anchors.fill: parent
        onClicked: settingsButton.clicked()
    }
}
