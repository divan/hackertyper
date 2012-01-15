// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0
import com.nokia.meego 1.0

Rectangle {
    id: pseudoKeyboard
    anchors.bottom: parent.bottom
    width: parent.width
    height: 200
    y: base.height - pseudoKbd.height;
    opacity: 1
    color: "#111111"
    border.color: "darkgreen"
    border.width: 1

    Column {
        spacing: 3
        anchors.centerIn: parent
        Row {
            spacing: 2
            KbdButton { value: "Tab"; keyWidth: 85 }
            KbdButton { value: "q" }
            KbdButton { value: "w" }
            KbdButton { value: "e" }
            KbdButton { value: "r" }
            KbdButton { value: "t" }
            KbdButton { value: "y" }
            KbdButton { value: "u" }
            KbdButton { value: "i" }
            KbdButton { value: "o" }
            KbdButton { value: "p" }
            KbdButton { value: "-"; keyWidth: 85; }
        }
        Row {
            spacing: 3
            KbdButton { value: "|" }
            KbdButton { value: "a" }
            KbdButton { value: "s" }
            KbdButton { value: "d" }
            KbdButton { value: "f" }
            KbdButton { value: "g" }
            KbdButton { value: "h" }
            KbdButton { value: "j" }
            KbdButton { value: "k" }
            KbdButton { value: "l" }
            KbdButton { value: "'" }
            KbdButton { value: "Enter"; keyWidth: 125 }
        }
        Row {
            spacing: 3
            KbdButton { value: "shift"; keyWidth: 105 }
            KbdButton { value: "z" }
            KbdButton { value: "x" }
            KbdButton { value: "c" }
            KbdButton { value: "v" }
            KbdButton { value: "b" }
            KbdButton { value: "n" }
            KbdButton { value: "m" }
            KbdButton { value: "," }
            KbdButton { value: "." }
            KbdButton { value: "shift"; keyWidth: 105 }
        }
    }

    states: State {
        name: 'hide'
        when: (root.state != "NORMAL" && root.state != "")
        PropertyChanges {
            target: pseudoKbd;
            height: 0
            opacity: 0;
            y: base.height
        }
    }

    transitions: Transition {
        NumberAnimation { properties: "opacity"; duration: 300 }
        NumberAnimation { properties: "y"; duration: 300; easing.type: Easing.InOutBack }
        NumberAnimation { properties: "height"; duration: 300; easing.type: Easing.InOutBack }
    }
}


