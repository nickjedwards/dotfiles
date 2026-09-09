import QtQuick
import QtQuick.Layouts
import qs.services

// What the notch shows when it is closed but something is playing.
//
// The art and the title are not drawn here. They are single objects that
// morph into the media panel (see NotchArt/NotchTitle), so this holds
// invisible stand-ins of exactly their size and reports where the layout put
// them. That keeps the visualiser positioned by the layout — it sits after
// whatever width the title actually took — without the strip owning either.
RowLayout {
    id: root

    readonly property real artX: art.x
    readonly property real artY: art.y
    readonly property real titleX: title.x
    readonly property real titleY: title.y
    readonly property real titleWidth: title.width
    readonly property real visualiserX: visualiser.x
    readonly property real visualiserY: visualiser.y

    // What the strip actually occupies, as opposed to what it was allotted.
    // The layout is given a fixed, generous width so it never has to reflow;
    // this is what the notch sizes itself to, so a short title doesn't leave
    // a hole between the visualiser and the clock.
    readonly property real contentWidth: art.width + title.width + visualiser.width + root.spacing * 2

    // The character cap, as the width it takes to draw exactly that many
    // characters of *this* title plus the ellipsis. Ten characters is not a
    // fixed width in a proportional font — "Illmatic O" and "Wilkommen"
    // differ by half again — so the cap is measured per track rather than
    // guessed once.
    //
    // Applied as a width because the visible title is a single object that
    // grows into the media panel and elides against whatever width it has
    // (see NotchTitle). Truncating the string instead would mean swapping
    // the text mid-flight, halfway through the notch opening.
    readonly property real titleCap: {
        // `metrics.font` is read rather than used: advanceWidth is a call,
        // and a call registers no dependency on the metrics behind it, so
        // without this the cap would be measured once — in whatever font the
        // metrics happened to have before the real one was applied — and
        // never corrected. It came out in Noto Sans at 16px, which is a third
        // wider than the title it was supposed to be measuring.
        metrics.font;
        return Math.ceil(metrics.advanceWidth(Media.title.slice(0, Config.barTitleChars) + "…"));
    }

    spacing: Config.barSpacing

    FontMetrics {
        id: metrics

        // The font the title is actually drawn in, rather than a second copy
        // of the same three lines to drift away from it.
        font: title.font
    }

    Item {
        id: art

        Layout.preferredWidth: Config.barArtSize
        Layout.preferredHeight: Config.barArtSize
        Layout.alignment: Qt.AlignVCenter
    }

    // Capped rather than filling. Filling would stretch this to whatever is
    // left over and pin the visualiser to the far right, so a short title
    // would sit in the middle of a wide empty box; capping lets the text hug
    // its own width and truncate only when it actually runs long.
    Text {
        id: title

        Layout.maximumWidth: root.titleCap
        Layout.alignment: Qt.AlignVCenter
        text: Media.title
        opacity: 0
        elide: Text.ElideRight
        font.family: Config.font
        font.pixelSize: Config.barTitleSize
        font.weight: Font.Medium
    }

    // A stand-in, like the art and the title above it.
    Item {
        id: visualiser

        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: Config.visualiserWidth
        Layout.preferredHeight: Config.barVisualiserHeight
    }

    // Takes the slack a short title leaves, so the three above stay packed
    // against the left instead of being spread across the strip.
    Item {
        Layout.fillWidth: true
    }
}
