// vim: ft=qml et ts=4 sw=4

import QtQuick 1.0
import com.nokia.meego 1.0

PageStackWindow {
    id: window
    showStatusBar: false
    showToolBar: false

    initialPage: Page {
        Main {
            anchors.fill: parent
        }
    }
}
