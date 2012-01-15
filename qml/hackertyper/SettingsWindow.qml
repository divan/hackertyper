// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0
import com.nokia.meego 1.0

Rectangle {
    id: settingsWindow
    width: parent.width
    height: parent.height
    visible: false
    color: "#000"

    states: State {
        name: 'show'
        PropertyChanges {
            target: settingsWindow;
            visible: true
        }
    }

    Column {
        width: parent.width
        height: parent.height
        spacing: 20
        anchors.topMargin: 25
        Text {
            width: parent.width
            text: "Hacker Typer"
            font.pixelSize: 72
            font.bold: true
            color: '#004400'
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            text: "Typing speed: " + speedSlider.value
            color: "white"
            width: parent.width * 0.8
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Slider {
            id: speedSlider
            stepSize: 1
            valueIndicatorVisible: false
            minimumValue:1
            maximumValue:30
            value: applicationData.speed
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
        }

        Rectangle {
            width: parent.width * 0.8
            height: 64
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id: closeBtn
                anchors.bottom: parent.bottom
                height: 64
                width: 128
                text: "Return"
                platformStyle: ButtonStyle{ inverted: true }
                onClicked: {
                    applicationData.speed = speedSlider.value;
                    settingsWindow.state = "";
                }
            }
            Button {
                id: restartBtn
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                height: 64
                width: 128
                text: "Restart"
                platformStyle: ButtonStyle{ inverted: true }
                onClicked: {
                    codeData.resetPosition();
                    textEdit.text = "";
                    settingsWindow.state = "";
                }
            }
        }
    }
}
