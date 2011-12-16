import QtQuick 1.0

/**
 * Makes a button for the Maemo 5 user interface.
 *
 * @author Copyright (c) Andrew Flegg 2011. Released under the Artistic Licence.
 */
Image {
    id: image

    property string icon
    signal clicked()

    anchors.top: parent.top
    source: '/etc/hildon/theme/images/' + icon + '.png'
    states: [
        State {
            name: 'PRESSED'
            when: button.pressed
            PropertyChanges { target: image; source: '/etc/hildon/theme/images/' + icon + 'Pressed.png' }
        }
    ]

    MouseArea {
        id: button
        anchors.fill: parent
        onClicked: {
            image.clicked()
        }
    }
}
