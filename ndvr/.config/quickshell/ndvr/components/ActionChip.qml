pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// One of a notification's actions, as a pill of its own label. What the label
// says is the sender's business — "Reply", "Snooze", "Mark as read" — so the
// pill is sized by its text rather than to a grid, up to the point where a
// sender is being unreasonable about it.
Item {
    id: root

    required property string label

    signal activated

    implicitWidth: Math.min(caption.implicitWidth + Config.notifActionPadX * 2, Config.notifActionMaxWidth)
    implicitHeight: Config.notifActionHeight

    scale: press.pressed ? 0.96 : 1

    Behavior on scale {
        NumberAnimation {
            duration: Config.pressDuration
        }
    }

    // A wash of the foreground rather than the palette's one grey. The chip
    // has to read as a step above whatever is behind it, and what is behind
    // it changes: the bare panel until the pointer is on the row, and then
    // the row's own hairline lozenge. A fixed grey disappears into one or the
    // other — hairline on hairline is exactly the problem the segmented
    // control's `trackColor` exists to dodge.
    //
    // Config.raise rather than a literal white, so this is a step *up* on a
    // dark theme and a step *down* on a light one. Hardcoded white was
    // invisible on Latte.
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: hover.hovered ? Config.raise(0.16) : Config.raise(0.09)

        Behavior on color {
            ColorAnimation {
                duration: Config.fadeDuration
            }
        }
    }

    Text {
        id: caption

        anchors.fill: parent
        anchors.leftMargin: Config.notifActionPadX
        anchors.rightMargin: Config.notifActionPadX
        text: root.label
        color: hover.hovered ? Config.text : Config.textDim
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: Config.font
        font.pixelSize: 11
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation {
                duration: Config.fadeDuration
            }
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    // ReleaseWithinBounds takes the press outright, which cancels the row's
    // own tap behind it. Without that, pressing a button would fire the
    // notification's default action as well as the one you asked for.
    TapHandler {
        id: press

        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.activated()
    }
}
