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

        Button {
            id: closeBtn
            height: 64
            width: 256
            text: "Return"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                applicationData.speed = speedSlider.value;
                settingsWindow.state = "";
            }
        }
    }
}
