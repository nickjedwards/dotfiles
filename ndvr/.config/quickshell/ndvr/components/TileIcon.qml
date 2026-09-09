pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.services

// Control-centre marks drawn as geometry rather than glyphs, for the same
// reason MediaButton is: no icon font has to be installed for the shell to
// look right.
//
// Everything but the wifi fan is laid out on the conventional 24-unit grid
// and scaled, so the marks stay in proportion with each other at any size.
Item {
    id: root

    // "wifi" | "bluetooth" | "output" | "input" | "brightness" | "back"
    // | "search" | "cpu" | "temp" | "memory" | "battery" | "close" | "bell"
    // | "power" | "restart" | "lock" | "logout"
    required property string kind
    required property color color

    property real size: 16

    // Only the bell reads this, and it passes true — the bell is only drawn
    // when there is something waiting. The hollow bell is still what the
    // outline gives you for free, and is what this is for if anything else
    // ever wants a mark with a quiet state.
    property bool filled: false

    // 0..1, and only the speaker reads it: how many of its three waves are
    // drawn. Defaults to all of them, so every other use of the mark — the
    // output tile's badge, which is about which device is selected rather
    // than how loud it is — gets a whole speaker without asking.
    property real level: 1

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 24
    readonly property real weight: Math.max(1.2, size * 0.09)

    // One arc of a circle, given in degrees on screen axes: 0 is to the
    // right and angles run clockwise, so 270 is the top. Every curved mark
    // here is one of these, which is why none of them need rotating into
    // place — the angles say where they open.
    component Sweep: Shape {
        id: sweep

        required property real cx
        required property real cy
        required property real radius
        required property real from
        required property real to
        required property color stroke
        required property real thickness

        preferredRendererType: Shape.CurveRenderer

        function px(deg: real): real {
            return cx + radius * Math.cos(deg * Math.PI / 180);
        }

        function py(deg: real): real {
            return cy + radius * Math.sin(deg * Math.PI / 180);
        }

        // PathArc draws the *minor* arc between two points unless told
        // otherwise, so anything over half a circle — the power ring, the
        // restart arrow — comes out as its own short complement.
        readonly property real sweepAngle: ((to - from) % 360 + 360) % 360

        ShapePath {
            strokeColor: sweep.stroke
            strokeWidth: sweep.thickness
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            startX: sweep.px(sweep.from)
            startY: sweep.py(sweep.from)

            PathArc {
                x: sweep.px(sweep.to)
                y: sweep.py(sweep.to)
                radiusX: sweep.radius
                radiusY: sweep.radius
                direction: PathArc.Clockwise
                useLargeArc: sweep.sweepAngle > 180
            }
        }
    }

    // Wifi: three arcs over a dot, struck from one centre below the icon so
    // the sweeps stay concentric.
    Item {
        id: wifi

        anchors.fill: parent
        visible: root.kind === "wifi"

        readonly property real cx: root.size / 2
        readonly property real cy: root.size * 0.78

        Sweep {
            anchors.fill: parent
            cx: wifi.cx
            cy: wifi.cy
            radius: root.size * 0.62
            from: 225
            to: 315
            stroke: root.color
            thickness: root.weight
        }

        Sweep {
            anchors.fill: parent
            cx: wifi.cx
            cy: wifi.cy
            radius: root.size * 0.41
            from: 225
            to: 315
            stroke: root.color
            thickness: root.weight
        }

        Sweep {
            anchors.fill: parent
            cx: wifi.cx
            cy: wifi.cy
            radius: root.size * 0.20
            from: 225
            to: 315
            stroke: root.color
            thickness: root.weight
        }

        Rectangle {
            x: wifi.cx - width / 2
            y: wifi.cy - height / 2
            width: root.weight * 1.4
            height: width
            radius: width / 2
            color: root.color
        }
    }

    // Bluetooth: the Hagall rune as one stroked polyline.
    Shape {
        anchors.fill: parent
        visible: root.kind === "bluetooth"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.weight
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            startX: 5 * root.u
            startY: 17 * root.u

            PathLine {
                x: 19 * root.u
                y: 7 * root.u
            }
            PathLine {
                x: 12 * root.u
                y: 1 * root.u
            }
            PathLine {
                x: 12 * root.u
                y: 23 * root.u
            }
            PathLine {
                x: 19 * root.u
                y: 17 * root.u
            }
            PathLine {
                x: 5 * root.u
                y: 7 * root.u
            }
        }
    }

    // Output: a filled speaker cone with two waves opening right.
    Item {
        anchors.fill: parent
        visible: root.kind === "output"

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: root.color
                strokeWidth: -1

                startX: 3 * root.u
                startY: 9 * root.u

                PathLine {
                    x: 7 * root.u
                    y: 9 * root.u
                }
                PathLine {
                    x: 12 * root.u
                    y: 4 * root.u
                }
                PathLine {
                    x: 12 * root.u
                    y: 20 * root.u
                }
                PathLine {
                    x: 7 * root.u
                    y: 15 * root.u
                }
                PathLine {
                    x: 3 * root.u
                    y: 15 * root.u
                }
                PathLine {
                    x: 3 * root.u
                    y: 9 * root.u
                }
            }
        }

        // Three waves rather than two, so the mark can count: silent, and
        // then a third of the way up for each one that lights. The radii are
        // 4/7/10 on the 24 grid — the outermost reaches 22 plus half a
        // stroke, which is the most that fits without touching the edge.
        Repeater {
            model: [
                { radius: 4, from: 0 },
                { radius: 7, from: 1 / 3 },
                { radius: 10, from: 2 / 3 }
            ]

            Sweep {
                required property var modelData

                anchors.fill: parent
                cx: 12 * root.u
                cy: 12 * root.u
                radius: modelData.radius * root.u
                from: 315
                to: 45
                stroke: root.color
                thickness: root.weight

                // Strictly greater, so a level of exactly zero — muted, or
                // wound all the way down — draws the cone on its own.
                opacity: root.level > modelData.from ? 1 : 0

                // Short enough to read as immediate under a drag, long
                // enough that a wave arrives rather than blinking on.
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.pressDuration
                    }
                }
            }
        }
    }

    // Input: a capsule over a cradle, on a stem.
    Item {
        anchors.fill: parent
        visible: root.kind === "input"

        Rectangle {
            x: 9 * root.u
            y: 2 * root.u
            width: 6 * root.u
            height: 12 * root.u
            radius: width / 2
            color: root.color
        }

        Sweep {
            anchors.fill: parent
            cx: 12 * root.u
            cy: 12 * root.u
            radius: 5.5 * root.u
            from: 0
            to: 180
            stroke: root.color
            thickness: root.weight
        }

        Rectangle {
            x: 12 * root.u - width / 2
            y: 17.5 * root.u
            width: root.weight
            height: 4.5 * root.u
            radius: width / 2
            color: root.color
        }
    }

    // Brightness: a disc with eight rays.
    Item {
        id: sun

        anchors.fill: parent
        visible: root.kind === "brightness"

        readonly property real reach: 11 * root.u

        Rectangle {
            anchors.centerIn: parent
            width: 9 * root.u
            height: width
            radius: width / 2
            color: root.color
        }

        Repeater {
            model: 8

            Rectangle {
                required property int index

                x: 12 * root.u - width / 2
                y: 12 * root.u - sun.reach
                width: root.weight
                height: 4 * root.u
                radius: width / 2
                color: root.color

                // Rotated about the icon's centre, which sits `reach` below
                // this rectangle's own top-left corner.
                transform: Rotation {
                    angle: index * 45
                    origin.x: root.weight / 2
                    origin.y: sun.reach
                }
            }
        }
    }

    // Back: a plain chevron.
    Shape {
        anchors.fill: parent
        visible: root.kind === "back"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.weight
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            startX: 15 * root.u
            startY: 4 * root.u

            PathLine {
                x: 8 * root.u
                y: 12 * root.u
            }
            PathLine {
                x: 15 * root.u
                y: 20 * root.u
            }
        }
    }

    // Search: a ring with a handle.
    Item {
        anchors.fill: parent
        visible: root.kind === "search"

        Rectangle {
            x: 3 * root.u
            y: 3 * root.u
            width: 13 * root.u
            height: width
            radius: width / 2
            color: "transparent"
            border.width: root.weight
            border.color: root.color
        }

        Rectangle {
            x: 14.5 * root.u
            y: 14.5 * root.u
            width: root.weight
            height: 7 * root.u
            radius: width / 2
            color: root.color
            transformOrigin: Item.TopLeft
            rotation: -45
        }
    }

    // CPU: a chip. Outline plus a solid core, and no pins — at the size these
    // are drawn a ring of pins turns into a smudge.
    Item {
        anchors.fill: parent
        visible: root.kind === "cpu"

        Rectangle {
            x: 5 * root.u
            y: 5 * root.u
            width: 14 * root.u
            height: width
            radius: 3 * root.u
            color: "transparent"
            border.width: root.weight
            border.color: root.color
        }

        Rectangle {
            anchors.centerIn: parent
            width: 5 * root.u
            height: width
            radius: 1.5 * root.u
            color: root.color
        }
    }

    // Temperature: a thermometer. The bulb is drawn over the stem's lower
    // end, so the stem's outline disappears into it and reads as one object.
    Item {
        anchors.fill: parent
        visible: root.kind === "temp"

        Rectangle {
            x: 9 * root.u
            y: 2 * root.u
            width: 6 * root.u
            height: 14 * root.u
            radius: width / 2
            color: "transparent"
            border.width: root.weight
            border.color: root.color
        }

        Rectangle {
            x: 8 * root.u
            y: 14.5 * root.u
            width: 8 * root.u
            height: width
            radius: width / 2
            color: root.color
        }
    }

    // Memory: stacked modules.
    Item {
        anchors.fill: parent
        visible: root.kind === "memory"

        Repeater {
            model: 3

            Rectangle {
                required property int index

                x: 4 * root.u
                y: (6 + index * 5.5) * root.u
                width: 16 * root.u
                height: 3.2 * root.u
                radius: height / 2
                color: root.color
            }
        }
    }

    // Battery: stood on end, to sit with the vertical meters it labels.
    Item {
        anchors.fill: parent
        visible: root.kind === "battery"

        Rectangle {
            x: 10.5 * root.u
            y: 2 * root.u
            width: 3 * root.u
            height: 2 * root.u
            radius: root.weight / 2
            color: root.color
        }

        Rectangle {
            x: 7.5 * root.u
            y: 4 * root.u
            width: 9 * root.u
            height: 18 * root.u
            radius: 2 * root.u
            color: "transparent"
            border.width: root.weight
            border.color: root.color
        }
    }

    // Close: a plain cross.
    Shape {
        anchors.fill: parent
        visible: root.kind === "close"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.weight
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            startX: 7 * root.u
            startY: 7 * root.u

            PathLine {
                x: 17 * root.u
                y: 17 * root.u
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.weight
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            startX: 17 * root.u
            startY: 7 * root.u

            PathLine {
                x: 7 * root.u
                y: 17 * root.u
            }
        }
    }

    // Bell: a dome on a base, with a clapper under it. The outline is left
    // open at the bottom, so filling it closes along the base line and the
    // solid mark is the same bell rather than a second drawing of one.
    Item {
        anchors.fill: parent
        visible: root.kind === "bell"

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.weight
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                // Fades in and out of the outline's own colour rather than
                // out of "transparent", which is a transparent *black* and
                // would take the fill through a grey that isn't in the
                // palette on its way.
                fillColor: root.filled ? root.color : Qt.rgba(root.color.r, root.color.g, root.color.b, 0)

                Behavior on fillColor {
                    ColorAnimation {
                        duration: Config.fadeDuration
                    }
                }

                startX: 4.5 * root.u
                startY: 17.5 * root.u

                PathLine {
                    x: 7 * root.u
                    y: 17.5 * root.u
                }
                PathLine {
                    x: 7 * root.u
                    y: 11 * root.u
                }
                PathArc {
                    x: 17 * root.u
                    y: 11 * root.u
                    radiusX: 5 * root.u
                    radiusY: 5.5 * root.u
                    direction: PathArc.Clockwise
                }
                PathLine {
                    x: 17 * root.u
                    y: 17.5 * root.u
                }
                PathLine {
                    x: 19.5 * root.u
                    y: 17.5 * root.u
                }
            }
        }

        Rectangle {
            x: 12 * root.u - width / 2
            y: 18.5 * root.u
            width: 3.6 * root.u
            height: width
            radius: width / 2
            color: root.color
        }
    }

    // Power: the IEC mark — a ring broken at the top, with a stem through it.
    Item {
        anchors.fill: parent
        visible: root.kind === "power"

        Sweep {
            anchors.fill: parent
            cx: 12 * root.u
            cy: 13 * root.u
            radius: 7.5 * root.u
            from: 290
            to: 250
            stroke: root.color
            thickness: root.weight
        }

        Rectangle {
            x: 12 * root.u - width / 2
            y: 2.5 * root.u
            width: root.weight
            height: 8 * root.u
            radius: width / 2
            color: root.color
        }
    }

    // Restart: a ring broken at the top, with an arrowhead closing it.
    Item {
        anchors.fill: parent
        visible: root.kind === "restart"

        Sweep {
            anchors.fill: parent
            cx: 12 * root.u
            cy: 12.5 * root.u
            radius: 7.5 * root.u
            from: 315
            to: 272
            stroke: root.color
            thickness: root.weight
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: root.color
                strokeWidth: -1

                startX: 11 * root.u
                startY: 2 * root.u

                PathLine {
                    x: 11 * root.u
                    y: 8 * root.u
                }
                PathLine {
                    x: 16.5 * root.u
                    y: 5 * root.u
                }
                PathLine {
                    x: 11 * root.u
                    y: 2 * root.u
                }
            }
        }
    }

    // Lock: a shackle over a body.
    Item {
        anchors.fill: parent
        visible: root.kind === "lock"

        Sweep {
            anchors.fill: parent
            cx: 12 * root.u
            cy: 10.5 * root.u
            radius: 4 * root.u
            from: 180
            to: 0
            stroke: root.color
            thickness: root.weight
        }

        Rectangle {
            x: 5.5 * root.u
            y: 10.5 * root.u
            width: 13 * root.u
            height: 10 * root.u
            radius: 2.5 * root.u
            color: "transparent"
            border.width: root.weight
            border.color: root.color
        }
    }

    // Log out: a doorway with an arrow leaving it.
    Item {
        anchors.fill: parent
        visible: root.kind === "logout"

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.weight
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"

                startX: 13 * root.u
                startY: 4 * root.u

                PathLine {
                    x: 5 * root.u
                    y: 4 * root.u
                }
                PathLine {
                    x: 5 * root.u
                    y: 20 * root.u
                }
                PathLine {
                    x: 13 * root.u
                    y: 20 * root.u
                }
            }

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.weight
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"

                startX: 10 * root.u
                startY: 12 * root.u

                PathLine {
                    x: 20 * root.u
                    y: 12 * root.u
                }
            }

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.weight
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"

                startX: 16.5 * root.u
                startY: 8.5 * root.u

                PathLine {
                    x: 20 * root.u
                    y: 12 * root.u
                }
                PathLine {
                    x: 16.5 * root.u
                    y: 15.5 * root.u
                }
            }
        }
    }
}
