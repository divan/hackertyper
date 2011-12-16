// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0

Rectangle {
    width: parent.width * 0.8
    height: width * 0.2
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    visible: false
    color: "darkgrey"
    property string msgColor: ""
    property string msgText: ""
    border.color: msgColor
    border.width: 1
    Text {
        color: msgColor
        text: msgText
        font.family: "monospace"
        font.pointSize: 48
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
