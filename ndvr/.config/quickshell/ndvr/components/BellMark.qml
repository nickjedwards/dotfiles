pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// The bell, at whatever size it is asked for. Always the solid, bright one:
// it is only ever on screen when something is waiting — Notch.showBell — so
// there is no quiet state for it to draw. Its being there is the whole of
// what it says.
//
// That is also what keeps the disappearance clean. Back when this dimmed and
// hollowed itself out for an empty list, clearing the panel would have had
// the mark change shape and colour on its way out rather than simply going.
//
// Presentation only, so the notification centre can hold an invisible one of
// exactly the right size to say where the real one should land. NotchBell is
// the one that moves.
Item {
    id: root

    property real iconSize: Config.barBellSize

    implicitWidth: root.iconSize
    implicitHeight: root.iconSize

    TileIcon {
        anchors.centerIn: parent
        kind: "bell"
        size: root.iconSize
        filled: true
        color: Config.text
    }
}
