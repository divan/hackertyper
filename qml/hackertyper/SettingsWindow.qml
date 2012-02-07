// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0
import com.nokia.meego 1.0
import com.nokia.extras 1.1

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

    Flickable {
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: settingsCol.height + 20
        flickableDirection: Flickable.VerticalFlick

        anchors.fill: parent

        Column {
            id: settingsCol
            width: parent.width
            spacing: 30
            anchors.topMargin: 25

            Text {
                width: parent.width
                text: "Hacker Typer"
                font.pixelSize: 72
                font.bold: true
                color: "lime"
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: "Typing speed: " + speedSlider.value
                color: "lime"
                font.pixelSize: 32
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

            Label {
                text: "Code file:"
                color: "lime"
                font.pixelSize: 32
                width: parent.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TumblerButton {
                id: codeTumblerButton
                text: codeData.file
                width: parent.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                style: TumblerButtonStyle { inverted: true }
                onClicked: codeDialog.open()
            }

            HackButton {
                id: hackBtn
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width * 0.8
                height: tipsText.height + 10
                color: "black"
                border.color: "green"
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    id: tipsText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "<b><u>Tips</u></b>:<br /><b>Enter</b> x 3 - Access Granted<br /><b>Tab</b> x 3 - Access Denied"
                    color: "green"
                }
            }
        } // Column
    } // Flickable

    TumblerDialog {
        id: codeDialog
        acceptButtonText: "OK"
        titleText: "Select file:"
        onAccepted: codeSelectCallback()
        columns: [ codeColumn ]
    }
    function codeSelectCallback()
    {
        var idx = codeColumn.selectedIndex;
        codeTumblerButton.text = codeColumn.items[idx];
        codeData.file = codeTumblerButton.text;
    }

    TumblerColumn {
        id: codeColumn
        items: codeData.getFiles()
        selectedIndex: 0
    }
}
