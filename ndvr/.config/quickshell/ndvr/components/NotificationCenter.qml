pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// The notification centre: everything the daemon has kept, newest first.
//
// A live surface, not just a log. Notifs holds each notification's D-Bus
// object for as long as its sender does, so dismissing a row tells the
// sender, and a row can offer whatever actions came with it.
Item {
    id: root

    // Where the bell should land when this panel is open. The panel keeps an
    // invisible one of exactly the right size — the same trick the clock, art
    // and title use — so the flying bell has somewhere exact to aim at.
    readonly property real bellX: heading.x + bellGhost.x
    readonly property real bellY: heading.y + bellGhost.y

    PanelHeading {
        id: heading

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: "Notifications"

        // Not drawn. The real bell flies in from the bar and lands on top of
        // it.
        BellMark {
            id: bellGhost

            anchors.right: parent.right
            anchors.rightMargin: Config.ccPadX
            anchors.verticalCenter: parent.line.verticalCenter
            opacity: 0
            iconSize: Config.panelBellSize
        }

        // Only offered when there is something to clear, so the panel never
        // shows an action that would do nothing. Just "Clear" — the list
        // under it is what says how much of it there is.
        Text {
            id: clear

            anchors.right: bellGhost.left
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.line.verticalCenter
            visible: Notifs.count > 0
            text: "Clear"
            color: clearHover.hovered ? Config.text : Config.textDim
            font.family: Config.font
            font.pixelSize: 11
            font.weight: Font.Medium

            Behavior on color {
                ColorAnimation {
                    duration: Config.fadeDuration
                }
            }

            HoverHandler {
                id: clearHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Notifs.clear()
            }
        }
    }

    ListView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: heading.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: Config.ccPadX
        anchors.rightMargin: Config.ccPadX
        anchors.topMargin: Config.panelHeadingGap
        anchors.bottomMargin: Config.ccPadX

        clip: true
        spacing: 2
        model: Notifs.history
        boundsBehavior: Flickable.StopAtBounds

        delegate: NotificationRow {
            required property var modelData

            width: ListView.view.width
            entry: modelData
            onDismissed: Notifs.dismiss(modelData.key)
            onInvoked: action => Notifs.invoke(modelData.key, action)
        }

        Text {
            anchors.centerIn: parent
            visible: Notifs.count === 0
            text: "Nothing new"
            color: Config.textDim
            font.family: Config.font
            font.pixelSize: 12
        }
    }
}
