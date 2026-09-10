pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services

// One notification in the centre: who sent it, how long ago, what it said,
// and what can still be done about it. The dismiss cross appears on hover
// rather than sitting in every row — twenty crosses down the panel is a list
// of crosses, not a list of notifications. The action buttons don't hide,
// because a button you have to go looking for is not a button.
//
// Built like the rows in the launcher and the device lists: the lozenge is
// the width of the list and the content is padded inside it.
Item {
    id: root

    required property var entry

    // Off inside a group that has a header, which already names the sender —
    // repeating it on every row would say "Chat" four times down a column
    // whose heading says Chat.
    property bool showApp: true

    // Set by the group while this row is being cleared. It slides out to the
    // right, fading as it goes, and then — unless something is about to take
    // its place — folds its height away, so the rows under it close up
    // rather than jump. The list is rebuilt whenever any notification
    // changes, and a row built already leaving starts out gone rather than
    // replaying the slide: Behaviors don't run on a property's first value.
    property bool leaving: false
    property bool foldOnLeave: true

    property real slide: root.leaving ? 1 : 0
    property real fold: root.leaving && root.foldOnLeave ? 1 : 0

    Behavior on slide {
        NumberAnimation {
            duration: Config.notifSlideDuration
            easing.type: Easing.InCubic
        }
    }

    Behavior on fold {
        SequentialAnimation {
            PauseAnimation {
                duration: Config.notifSlideDuration
            }

            NumberAnimation {
                duration: Config.notifCollapseDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    enabled: !root.leaving
    opacity: 1 - root.slide
    clip: root.fold > 0

    transform: Translate {
        x: root.slide * root.width
    }

    // The sender's own object, while it still has one. Only a live
    // notification can be acted on, and only it knows about a replacement.
    readonly property var live: root.entry.notification

    // What to draw: the live object where there is one, the copy taken on
    // arrival where the sender has since closed it.
    readonly property var view: Notifs.view(root.entry)

    readonly property var actions: root.live ? root.live.actions.filter(action => action.identifier !== "default") : []

    // Not a button. The spec's "default" action is what clicking the
    // notification itself does, so the row carries it rather than drawing it
    // at the end of the others.
    readonly property var defaultAction: root.live ? (root.live.actions.find(action => action.identifier === "default") || null) : null

    signal dismissed
    signal invoked(action: var)

    implicitHeight: (Config.notifRowHeight + (root.actions.length > 0 ? buttons.implicitHeight + Config.notifActionGap : 0)) * (1 - root.fold)

    RowHighlight {
        on: hover.hovered
    }

    HoverHandler {
        id: hover
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    // The default action, on the row itself.
    //
    // The cross and the buttons used to take the press outright to cancel
    // this one, but an exclusive grab is refused inside a ListView — the
    // Flickable has one — so they never tapped at all. Everything here is a
    // passive grab now, which means this handler and a control's both fire
    // on the same press, in no guaranteed order. Hence the guard: a tap that
    // landed on a control is that control's, not the row's.
    function overControl(pos: point): bool {
        if (closeMark.visible && closeMark.contains(closeMark.mapFromItem(root, pos)))
            return true;
        if (buttons.visible && buttons.contains(buttons.mapFromItem(root, pos)))
            return true;

        return false;
    }

    TapHandler {
        enabled: root.defaultAction !== null

        onTapped: eventPoint => {
            if (root.overControl(eventPoint.position))
                return;

            root.invoked(root.defaultAction);
        }
    }

    ClippingRectangle {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Config.rowPadX
        anchors.top: parent.top
        anchors.topMargin: 10
        width: Config.notifIconSize
        height: Config.notifIconSize
        radius: 8
        color: Config.hairline

        // The notification's own image where there is one — message avatars
        // and album art — and the sending application's icon otherwise.
        IconImage {
            anchors.fill: parent
            anchors.margins: root.view.image ? 0 : 6
            source: root.view.image ? root.view.image : Notifs.appIconSource(root.view.appIcon)
            asynchronous: true
        }
    }

    ColumnLayout {
        anchors.left: icon.right
        anchors.leftMargin: 11
        anchors.right: parent.right
        anchors.rightMargin: Config.rowPadX
        anchors.top: parent.top
        anchors.topMargin: 8
        spacing: 1

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                visible: root.showApp
                text: root.entry.appName
                color: Config.textDim
                font.family: Config.font
                font.pixelSize: 10
                font.weight: Font.Medium
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                visible: root.entry.urgent
                width: 5
                height: 5
                radius: 2.5
                color: Config.urgent
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                // Time.now is read here so this re-evaluates every minute;
                // Notifs.formatAge deliberately doesn't read the clock.
                text: Notifs.formatAge(root.entry.time, Time.now)
                color: Config.textDim
                visible: !hover.hovered
                font.family: Config.font
                font.pixelSize: 10
            }

            // Takes the age's place rather than sitting beside it, so the row
            // doesn't reflow under the pointer.
            TileIcon {
                id: closeMark

                Layout.alignment: Qt.AlignVCenter
                visible: hover.hovered
                kind: "close"
                size: 13
                color: close.hovered ? Config.text : Config.textDim

                HoverHandler {
                    id: close
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.dismissed()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.view.summary
            color: Config.text
            elide: Text.ElideRight
            textFormat: Text.PlainText
            font.family: Config.font
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: Notifs.bodyBlock(root.view.body)
            color: Config.textDim
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            textFormat: Text.PlainText
            font.family: Config.font
            font.pixelSize: 11
        }

        // A Flow rather than a Row: a sender can send as many actions as it
        // likes, and the row is told how tall this came out rather than
        // assuming one line of them.
        Flow {
            id: buttons

            Layout.fillWidth: true
            Layout.topMargin: Config.notifActionGap
            visible: root.actions.length > 0
            spacing: Config.notifActionSpacing

            Repeater {
                model: root.actions

                ActionChip {
                    required property var modelData

                    label: modelData.text
                    onActivated: root.invoked(modelData)
                }
            }
        }
    }
}
