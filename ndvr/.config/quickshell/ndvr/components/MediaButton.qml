pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.services

// Transport controls drawn as geometry rather than glyphs, so they don't
// depend on an icon font being installed.
Item {
    id: root

    // "previous" | "next" | "play" | "pause"
    required property string kind

    // `enabled` is Item's own property — setting it false also stops the
    // handlers below from firing, which is exactly what we want.
    property real size: 15

    signal activated

    implicitWidth: 34
    implicitHeight: 34

    opacity: enabled ? (hover.hovered ? 1 : 0.82) : 0.28
    Behavior on opacity {
        NumberAnimation {
            duration: Config.fadeDuration
        }
    }

    scale: press.pressed ? 0.88 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Config.pressDuration
        }
    }

    HoverHandler {
        id: hover
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: press
        enabled: root.enabled
        onTapped: root.activated()
    }

    Item {
        anchors.centerIn: parent
        width: root.size
        height: root.size

        // Pause: two bars.
        Row {
            anchors.centerIn: parent
            visible: root.kind === "pause"
            spacing: Math.round(root.size * 0.28)

            Repeater {
                model: 2

                Rectangle {
                    width: Math.round(root.size * 0.24)
                    height: root.size
                    radius: width / 2
                    color: Config.text
                }
            }
        }

        // Play: single triangle. Previous/next: triangle plus a stop bar,
        // mirrored by the parent's scale.
        Item {
            anchors.fill: parent
            visible: root.kind !== "pause"
            transform: Scale {
                origin.x: root.size / 2
                origin.y: root.size / 2
                xScale: root.kind === "previous" ? -1 : 1
            }

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: Config.text
                    strokeWidth: -1

                    startX: root.kind === "play" ? 1 : 0
                    startY: 0
                    PathLine {
                        x: root.kind === "play" ? root.size - 1 : root.size * 0.78
                        y: root.size / 2
                    }
                    PathLine {
                        x: root.kind === "play" ? 1 : 0
                        y: root.size
                    }
                    PathLine {
                        x: root.kind === "play" ? 1 : 0
                        y: 0
                    }
                }
            }

            Rectangle {
                visible: root.kind !== "play"
                anchors.right: parent.right
                width: Math.round(root.size * 0.18)
                height: root.size
                radius: width / 2
                color: Config.text
            }
        }
    }
}
