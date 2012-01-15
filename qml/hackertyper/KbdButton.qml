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
            root.state = "NORMAL";

            if (value == "Enter")
            {
                if (root.counterGranted > 2)
                {
                    root.state = "ACCESS_GRANTED";
                    root.counterGranted = 0;
                }
                root.counterGranted++;
            }
            else if (value == ",")
            {
                if (root.counterDenied > 2)
                {
                    root.state = "ACCESS_DENIED";
                    root.counterDenied = 0;
                }
                root.counterDenied++;
            }

            if (value == "-")
            {
                var str = textEdit.text;
                textEdit.text = str.substring(0,
                                    str.length - applicationData.speed);
                codeData.pos -= applicationData.speed
            }
            else
            {
                textEdit.text += codeData.getNextCode(applicationData.speed);
            }
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
