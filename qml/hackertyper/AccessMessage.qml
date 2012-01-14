// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    id: accessMessage
    width: parent.width * 0.8
    height: width * 0.2
    x: root.width/2 - width/2
    y: root.height/2 - height/2
    visible: false
    opacity: 0

    states: State {
        name: 'show'
        PropertyChanges {
            target: accessMessage;
            visible: true
            opacity: 1
        }
    }

    color: "darkgrey"
    property string msgColor: ""
    property string msgText: ""
    border.color: msgColor
    border.width: 1
    Text {
        color: msgColor
        text: msgText
        anchors.fill: parent
        font.family: "monospace"
        font.pointSize: 48
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.state = "NORMAL"
    }

    transitions: Transition {
        NumberAnimation { properties: "opacity"; duration: 600; easing.type: Easing.InOutBack; }
    }
}
