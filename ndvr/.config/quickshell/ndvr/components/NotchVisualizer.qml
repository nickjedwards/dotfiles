pragma ComponentBehavior: Bound

import qs.services

// The visualiser, morphing between the closed bar and the far right of the
// title in the media panel — the same journey the art and the title make, for
// the same reason: it is one object that moves, not two that cross-fade.
//
// Only the bar height interpolates. The Row's width is its natural one at
// both ends, so there is nothing to reflow as it travels.
Visualizer {
    id: root

    property real morph: 0

    property real collapsedX: 0
    property real collapsedY: 0
    property real expandedX: 0
    property real expandedY: 0

    // Position rides the overshoot with the shape; the bars do not, because
    // bars briefly taller than their final height read as a spike in the
    // audio rather than as motion.
    readonly property real sizeMorph: Math.max(0, Math.min(1, morph))

    x: collapsedX + (expandedX - collapsedX) * morph
    y: collapsedY + (expandedY - collapsedY) * morph

    barHeight: Config.barVisualiserHeight + (Config.panelVisualiserHeight - Config.barVisualiserHeight) * sizeMorph
}
