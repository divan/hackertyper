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
        contentHeight: settingsItem.height + 20
        flickableDirection: Flickable.VerticalFlick
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: settingsItem
            width: parent.width * 0.8
            color: "transparent"
            height: (screen.currentOrientation == Screen.Portrait) ? 800 : 550
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: title
                anchors.top: settingsItem.top
                anchors.margins: 25
                width: parent.width
                text: "Hacker Typer"
                font.pixelSize: 72
                font.bold: true
                color: "lime"
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: typingLabel
                anchors.top: title.bottom
                anchors.margins: 25
                text: "Typing speed: " + speedSlider.value
                color: "lime"
                font.pixelSize: 32
            }

            Slider {
                id: speedSlider
                anchors.top: (screen.currentOrientation == Screen.Portrait) ? typingLabel.bottom : title.bottom
                anchors.left: (screen.currentOrientation == Screen.Portrait) ? typingLabel.left : typingLabel.right
                anchors.margins: 25
                stepSize: 1
                valueIndicatorVisible: false
                minimumValue:1
                maximumValue:30
                value: applicationData.speed
            }

            Label {
                id: codeLabel
                anchors.top: speedSlider.bottom
                anchors.margins: 25
                text: "Code file:"
                color: "lime"
                font.pixelSize: 32
            }

            TumblerButton {
                id: codeTumblerButton
                anchors.top: (screen.currentOrientation == Screen.Portrait) ? codeLabel.bottom : speedSlider.bottom
                anchors.left: (screen.currentOrientation == Screen.Portrait) ? codeLabel.left : codeLabel.right
                width: (screen.currentOrientation == Screen.Portrait) ? parent.width : parent.width - codeLabel.width
                anchors.margins: 25
                text: codeData.file
                style: TumblerButtonStyle { inverted: true }
                onClicked: codeDialog.open()
            }

            Rectangle {
                id: tipsRectangle
                anchors.margins: 25
                anchors.top: (screen.currentOrientation == Screen.Portrait) ? codeTumblerButton.bottom : hackBtn.bottom
                width: parent.width
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

            HackButton {
                id: hackBtn
                anchors.margins: 45
                anchors.top: (screen.currentOrientation == Screen.Portrait) ? tipsRectangle.bottom : codeTumblerButton.bottom
                anchors.horizontalCenter: parent.horizontalCenter
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
