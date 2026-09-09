pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// Four bars that breathe while something is playing. The animations are
// bound to isPlaying, so a paused or absent player costs nothing — no
// timers, no frame requests.
//
// The animation drives a separate `level` property rather than `height`
// directly, because a property cannot have both a binding and an animation
// attached to it.
//
// To drive these from real audio, run cava with raw output through a
// Process + SplitParser in a singleton and bind each bar's level to it.
Row {
    id: root

    property color color: Config.text
    property real barHeight: 13

    spacing: 3
    height: barHeight

    Repeater {
        model: 4

        Rectangle {
            id: bar

            required property int index
            property real level: 0

            width: 2.5
            radius: 1.5
            color: root.color
            height: 3 + bar.level * (root.barHeight - 3)
            y: (root.height - height) / 2

            SequentialAnimation on level {
                running: Media.isPlaying && root.visible
                loops: Animation.Infinite
                alwaysRunToEnd: true

                NumberAnimation {
                    to: 1
                    duration: 300 + bar.index * 95
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 0
                    duration: 360 + bar.index * 65
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
