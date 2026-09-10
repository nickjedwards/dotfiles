pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// Everything one sender has waiting, as one item in the centre.
//
// A group of one is just a notification: no header, no count, nothing to
// expand — it draws exactly as it did before there was any grouping, because
// that is what most of them are. Only a second notification from the same
// sender turns it into a group, and then the header appears to carry what
// applies to the whole of it: the name, how many, and clearing the lot.
//
// Collapsed shows the newest one, which is the one you would have seen
// anyway. Older ones are a click away rather than a scroll away, so ten
// notifications from one chat cost the panel one row instead of ten.
Item {
    id: root

    required property var group
    required property bool expanded

    // Keys of the entries being cleared one at a time, from the centre.
    property var leavingKeys: ({})

    // The whole group being cleared, by its own Clear or the panel's. It
    // slides out as one — header and rows together — after `leaveDelay`,
    // which is how Clear sends the groups out one after another, and folds
    // away afterwards unless the whole list is going anyway.
    property bool leaving: false
    property bool foldOnLeave: true
    property int leaveDelay: 0

    signal toggled
    signal groupDismissed
    signal dismissed(int key, bool folds)
    signal invoked(int key, var action)

    readonly property var entries: root.group.entries

    // What is left once the ones on their way out are gone. The header, the
    // indent and the count go by this rather than by `entries`, so a group
    // cleared down to one turns back into a plain notification while the
    // last-but-one is still sliding away, instead of snapping at the end.
    readonly property var remaining: root.entries.filter(e => root.leavingKeys[e.key] !== true)
    readonly property bool grouped: root.remaining.length > 1

    // Collapsed to its newest. Goes by `entries`, not `remaining`: clearing
    // the newest of a collapsed group slides it out and lets the next one
    // take its place, rather than opening the group up underneath it.
    //
    // Only the newest is drawn then — but from the same component and the
    // same entry it would use expanded, so nothing about a row changes
    // depending on how much of its group is showing.
    readonly property bool stacked: root.entries.length > 1 && !root.expanded
    readonly property var shown: root.stacked ? [root.entries[0]] : root.entries

    property real slide: root.leaving ? 1 : 0
    property real fold: root.leaving && root.foldOnLeave ? 1 : 0

    Behavior on slide {
        SequentialAnimation {
            PauseAnimation {
                duration: root.leaveDelay
            }

            NumberAnimation {
                duration: Config.notifSlideDuration
                easing.type: Easing.InCubic
            }
        }
    }

    Behavior on fold {
        SequentialAnimation {
            PauseAnimation {
                duration: root.leaveDelay + Config.notifSlideDuration
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

    // The gap to the next group is the group's own rather than the list's
    // spacing, so folding away takes it too. ListView spacing would stay
    // behind as a 6px step for the rows below to jump when the entry is
    // finally dropped.
    implicitHeight: (column.implicitHeight + Config.notifGroupSpacing) * (1 - root.fold)

    Behavior on implicitHeight {
        // Only for opening and closing the group. While anything in it is
        // leaving, the height is already being animated from below, and a
        // Behavior on top would chase it every frame and land late.
        enabled: !root.leaving && root.remaining.length === root.entries.length

        NumberAnimation {
            duration: Config.fadeDuration
            easing.type: Easing.OutCubic
        }
    }

    Column {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        // ── Header ───────────────────────────────────────────────────────
        // Two separate targets side by side rather than one strip with a
        // control sitting on top of it. The toggle is the chevron, the name
        // and the count; "Clear" is its own item to the right and they do
        // not overlap, so neither has to beat the other to a press.
        //
        // Both use the default gesture policy, which takes a *passive* grab.
        // That matters inside a ListView: the Flickable takes the exclusive
        // grab on press to see whether you are flicking, so a handler asking
        // for an exclusive one — ReleaseWithinBounds — is refused and never
        // taps at all. That is what made this button dead: it saw the hover,
        // never the click. A passive grab survives alongside the Flickable's
        // and fires on release.
        Item {
            id: header

            width: parent.width

            // Folds rather than vanishing, for a group cleared down to one.
            height: root.grouped ? Config.notifGroupHeaderHeight : 0
            visible: height > 0
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: Config.notifCollapseDuration
                    easing.type: Easing.OutCubic
                }
            }

            // Spans the whole strip, so "Clear" appears whenever the group is
            // under the pointer rather than only over its own few pixels.
            HoverHandler {
                id: headerHover
            }

            Item {
                id: toggleTarget

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: chevron.width + 8 + name.implicitWidth + 7 + count.implicitWidth + Config.rowPadX * 2

                RowHighlight {
                    on: toggleHover.hovered
                }

                HoverHandler {
                    id: toggleHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.toggled()
                }

                TileIcon {
                    id: chevron

                    anchors.left: parent.left
                    anchors.leftMargin: Config.rowPadX
                    anchors.verticalCenter: parent.verticalCenter
                    kind: "back"
                    size: 13
                    color: toggleHover.hovered ? Config.text : Config.textDim

                    // "back" points left, and positive rotation is clockwise
                    // — so 90 is up and -90 is down. Collapsed points down at
                    // what would open below it; expanded points up at what is
                    // about to fold away.
                    rotation: root.expanded ? 90 : -90

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Config.fadeDuration
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.fadeDuration
                        }
                    }
                }

                Text {
                    id: name

                    anchors.left: chevron.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.group.appName
                    color: Config.text
                    font.family: Config.font
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                // How many are in here, which is the number the collapsed
                // state is hiding. Counts down as they are cleared, not when
                // the last slide finishes.
                Text {
                    id: count

                    anchors.left: name.right
                    anchors.leftMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.remaining.length
                    color: Config.textDim
                    font.family: Config.font
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            // Clears the sender, not the panel. Appears on hover for the same
            // reason the per-row cross does: a column of standing "Clear"s is
            // a column of Clears, not a list of notifications.
            //
            // An item around the word rather than the word itself — the text
            // is 25px by 13, which is a thing to read, not a thing to hit.
            Item {
                id: clearTarget

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: clearLabel.implicitWidth + Config.rowPadX * 2
                visible: headerHover.hovered

                RowHighlight {
                    on: clearHover.hovered
                }

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.groupDismissed()
                }

                Text {
                    id: clearLabel

                    anchors.centerIn: parent
                    text: "Clear"
                    color: clearHover.hovered ? Config.text : Config.textDim
                    font.family: Config.font
                    font.pixelSize: 10
                    font.weight: Font.Medium

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.fadeDuration
                        }
                    }
                }
            }
        }

        // ── The notifications ────────────────────────────────────────────
        Repeater {
            model: root.shown

            NotificationRow {
                required property var modelData

                // Indented under the header so the group reads as one thing
                // with a heading, rather than a heading and some rows that
                // happen to follow it. Eases back out as the header folds.
                x: root.grouped ? Config.notifGroupIndent : 0
                width: column.width - x

                Behavior on x {
                    NumberAnimation {
                        duration: Config.notifCollapseDuration
                        easing.type: Easing.OutCubic
                    }
                }

                entry: modelData

                // The header already says who this is from.
                showApp: !root.grouped

                // The newest of a collapsed group has the next one coming in
                // behind it, so it slides without folding.
                leaving: root.leavingKeys[modelData.key] === true
                foldOnLeave: !root.stacked

                onDismissed: root.dismissed(modelData.key, !root.stacked)
                onInvoked: action => root.invoked(modelData.key, action)
            }
        }
    }
}
