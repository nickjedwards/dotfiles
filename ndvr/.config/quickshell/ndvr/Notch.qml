pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// One notch window per monitor.
//
// Three ideas do most of the work here:
//
//  1. The window never resizes. It is created once at the size of the
//     largest state and stays there, transparent, with an input mask
//     restricting clicks to the notch itself. Animating a layer-shell
//     surface's size means renegotiating with the compositor every frame;
//     animating a shape inside a fixed surface does not.
//
//  2. The mask follows the *target* geometry, not the animated geometry,
//     so it changes twice per interaction instead of sixty times a second.
//
//  3. The closed bar is three things side by side — the bell, the time, then
//     now playing — and which of them the pointer entered decides which
//     panel opens. The notch is one window and one shape throughout; only
//     its contents and its target size differ.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    // Only the top anchor, so layer-shell centres the surface horizontally.
    anchors.top: true

    // A notch overlays the screen, it does not reserve space.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:ndvr"

    // Only the keyboard-driven panels want the keyboard, and only while they
    // are up. Asking for it the rest of the time would take focus off
    // whatever you were typing into every time the notch so much as widened
    // for a track change. None of them can be reached by hovering the bar,
    // so any of them being open is already something you asked for.
    readonly property bool wantsKeyboard: root.mode === "launcher" || root.mode === "wallpaper" || root.mode === "theme"

    WlrLayershell.keyboardFocus: root.wantsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Sized for the largest state, once, forever — plus room for the shadow
    // to fall into. The extra is transparent and outside the input mask, so
    // it costs nothing but the space it reserves.
    implicitWidth: Config.maxWidth + Config.cornerRadius * 2 + Config.hoverPadX * 2 + Config.shadowMargin * 2
    implicitHeight: Config.maxHeight + Config.hoverPadY * 2 + Config.shadowMargin

    // ── State ────────────────────────────────────────────────────────────

    // Which half of the closed bar the pointer entered, and so which panel is
    // open. "" is closed, otherwise "media" or "control". A forced-open panel
    // from IPC counts the same way.
    property string hoverTarget: ""
    property bool peeking: false

    // A pin beats a hover, not the other way round: pressing the launcher
    // keybind while the pointer happens to rest on the notch should open the
    // launcher, and before this it silently did nothing at all.
    readonly property string openTarget: NotchState.forced !== "" ? NotchState.forced : root.hoverTarget
    readonly property bool opened: root.openTarget !== ""

    // Whether the bar has a now-playing third at all. Deliberately hasPlayer
    // rather than isPlaying: the media third has to be a stable thing to aim
    // at, and a paused track is exactly when you want the transport controls.
    readonly property bool showMedia: Media.hasPlayer

    // The bell is only in the bar when it has something to say. Nothing
    // waiting is the ordinary state, and a mark that is on screen all day to
    // report it is a mark you stop seeing — so the bar earns back the width
    // and the bell means something when it appears.
    //
    // Unlike showMedia this is not a stable thing to aim at, and it does not
    // pretend to be: the notification centre is still one keybind away when
    // the bell is gone, which is the only way to reach the history of what
    // you have already dismissed.
    readonly property bool showBell: Notifs.count > 0

    readonly property string mode: {
        if (root.opened) {
            if (root.openTarget === "control")
                return "control";
            if (root.openTarget === "launcher")
                return "launcher";
            if (root.openTarget === "notifications")
                return "notifications";
            if (root.openTarget === "power")
                return "power";
            if (root.openTarget === "wallpaper")
                return "wallpaper";
            if (root.openTarget === "theme")
                return "theme";
            return "media";
        }
        if (root.peeking)
            return "notify";
        if (root.showMedia)
            return "bar";
        return "idle";
    }

    readonly property real targetWidth: {
        switch (root.mode) {
        case "media":
            return Config.mediaPanelWidth;
        case "control":
            return Config.ccWidth;
        case "launcher":
            return Config.launcherWidth;
        case "notifications":
            return Config.notifPanelWidth;
        case "power":
            return Config.powerMenuWidth;
        case "wallpaper":
            return Config.wallpaperWidth;
        case "theme":
            return Config.themePanelWidth;
        case "notify":
            return Config.peekWidth;
        case "bar":
            // Sized to its contents rather than to a worst case, so a short
            // title doesn't leave a hole after the clock. The clock and bell
            // widths are their own; nothing here feeds back into them, so
            // there is no loop.
            return Config.barPadX * 2 + root.bellBlockWidth + clock.width + Config.barGap + root.barContentWidth;
        default:
            return Config.barPadX * 2 + clock.width + root.bellBlockWidth;
        }
    }

    readonly property real targetHeight: {
        switch (root.mode) {
        case "media":
            return Config.mediaPanelHeight;
        case "control":
            return Config.ccHeight;
        case "launcher":
            return Config.launcherHeight;
        case "notifications":
            return Config.notifPanelHeight;
        case "power":
            return Config.powerMenuHeight;
        case "wallpaper":
            return Config.wallpaperHeight;
        case "theme":
            return Config.themePanelHeight;
        case "notify":
            return Config.peekHeight;
        case "bar":
            return Config.barHeight;
        default:
            return Config.idleHeight;
        }
    }

    // The clock is the one piece of content that no state owns: it sits in
    // the bar when the notch is closed and grows into the control centre when
    // that one opens, as a single object rather than two that cross-fade.
    property real clockMorph: root.openTarget === "control" ? 1 : 0

    // Every Behavior below springs on the way in and settles on the way out.
    // OutBack overshoots whichever direction it is given, so using it for
    // both meant a panel closing shrank past its mark and came back — a
    // wobble rather than a spring, and the one bit of motion here that drew
    // attention to itself instead of to what it was carrying.
    //
    // The test is the same expression that computes each target, rather than
    // a blanket "is anything open": switching straight from one panel to
    // another has one morph arriving and another leaving at the same moment,
    // and they want opposite curves.

    // The bell and the gap after it, which the clock starts beyond — and
    // nothing at all when there is no bell, so the bar closes up rather than
    // holding a space for it. Every measurement below is expressed in terms
    // of this, so that is the whole of what appearing and disappearing
    // costs.
    readonly property real bellBlockWidth: root.showBell ? Config.barBellGap + bell.width : 0

    // Where the closed bar's three things sit, in one place rather than
    // scattered across the items that use them — the hover zones below are
    // read off exactly the same numbers the elements are drawn at, so the
    // two cannot drift.
    //
    // The bell and the clock are measured from the left edge, which is a
    // constant, so neither moves while the notch grows underneath them. Now
    // playing is the one measured from the right, against live geometry
    // rather than the target width, so it stays correctly placed for every
    // frame of that growth instead of jumping at the end of it.
    //
    // It is positioned by its *content* width, not the width of the box it
    // is loaded into: CollapsedMedia packs its row to the left of a
    // generously-sized layout, so anchoring the box would leave the slack
    // between the title and the padding rather than after it.
    readonly property real barBellX: Config.barPadX
    readonly property real barClockX: Config.barPadX + root.bellBlockWidth
    readonly property real barMediaX: contentClip.width - Config.barPadX - root.barContentWidth

    // What the now-playing group actually occupies. Falls back to the widest
    // it could be, so the first frame is never too narrow for its contents.
    readonly property real barContentWidth: root.barItem ? root.barItem.contentWidth : Config.barMediaWidth

    // The art and the title do the same journey between the closed bar and
    // the media panel that the clock does between the bar and the control
    // centre — one object growing, not two cross-fading.
    property real mediaMorph: root.mode === "media" ? 1 : 0

    // Null until the panels finish preloading, which is why every landing
    // point below is guarded.
    readonly property ControlCenter controlItem: controlCentre.item as ControlCenter
    readonly property MediaPanel mediaItem: mediaPanel.item as MediaPanel
    readonly property CollapsedMedia barItem: barMedia.item as CollapsedMedia
    readonly property NotificationCenter notifItem: notifications.item as NotificationCenter

    // The bell's journey, from the right of the closed bar to the right of
    // the notification centre's heading.
    property real notifMorph: root.mode === "notifications" ? 1 : 0

    Behavior on clockMorph {
        NumberAnimation {
            duration: Config.growDuration
            easing.type: root.openTarget === "control" ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: Config.overshoot
        }
    }

    Behavior on notifMorph {
        NumberAnimation {
            duration: Config.growDuration
            easing.type: root.mode === "notifications" ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: Config.overshoot
        }
    }

    Behavior on mediaMorph {
        NumberAnimation {
            duration: Config.growDuration
            easing.type: root.mode === "media" ? Easing.OutBack : Easing.OutCubic
            easing.overshoot: Config.overshoot
        }
    }

    // Leaving the notch does not collapse it immediately — otherwise it
    // flickers every time the pointer crosses the top of the screen.
    Timer {
        id: collapseTimer
        interval: Config.collapseDelay

        // Re-checked rather than trusted. If something inside the panel takes
        // the hover for a moment on the way past, the exit that started this
        // timer was a lie — and closing on it would collapse the notch out
        // from under whatever the pointer was reaching for.
        onTriggered: {
            if (pointer.hovered)
                return;
            root.hoverTarget = "";
        }
    }

    Timer {
        id: peekTimer
        interval: Config.peekDuration
        onTriggered: root.peeking = false
    }

    Connections {
        target: Notifs

        function onPeeked(): void {
            // Don't interrupt someone who is already using a panel.
            if (root.opened)
                return;
            root.peeking = true;
            peekTimer.restart();
        }
    }

    // ── Input ────────────────────────────────────────────────────────────

    // The closed bar is three things, and each leads somewhere: the bell, the
    // time, now playing. The boundaries are taken from where those elements
    // are laid out rather than from configured zone widths, so they cannot
    // drift out of step with what is drawn. Each gap is split down the
    // middle, so there is no dead ground between two zones.
    readonly property real zoneOffset: (hitArea.width - contentClip.width) / 2

    function targetAt(x: real): string {
        const bodyX = x - root.zoneOffset;

        // Guarded on the bell being there at all: without it barClockX is
        // just the padding, and the leftmost sliver of the bar — the hover
        // pad included, where bodyX is negative — would still open a
        // notification centre nothing had pointed you at.
        if (root.showBell && bodyX < root.barClockX - Config.barBellGap / 2)
            return "notifications";

        // With no player there is no right third, so everything past the
        // bell is the time.
        if (!root.showMedia || bodyX < root.barMediaX - Config.barGap / 2)
            return "control";

        return "media";
    }

    // Sized to the target geometry, never animated. Doubles as the window's
    // input mask, so everything outside it is click-through.
    //
    // Deliberately raised above the panels. Hover is tracked here, and the
    // panel content is a sibling drawn on top of it — so at z 0 the first
    // tile the pointer crossed would take the hover, this would see an exit,
    // and the notch would collapse out from under whatever you were reaching
    // for. Raising it means nothing can take the hover away.
    //
    // Raising it costs nothing in clicks because there is no MouseArea here:
    // a non-blocking HoverHandler passes hover through to the tiles below, and
    // a right-button TapHandler never grabs a left press, so taps land on the
    // panel exactly as before.
    // Sized to the target geometry, never animated. Doubles as the window's
    // input mask, so everything outside it is click-through.
    //
    // The shape and the content live inside it, and that nesting is what
    // makes hover work. A HoverHandler reports on geometric containment in
    // the item it is attached to, so an ancestor stays hovered while the
    // pointer is over any of its descendants — the tiles keep their own
    // hover effects and the notch still knows the pointer is inside it.
    //
    // As a sibling this cannot work either way round: below the content, the
    // first tile the pointer crossed took the hover and the notch collapsed
    // out from under it; above the content, the notch kept the hover and the
    // tiles never lit up.
    //
    // There is no MouseArea here, and the TapHandler accepts only the right
    // button, so left presses fall straight through to the controls inside.
    Item {
        id: hitArea

        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: root.targetWidth + Config.cornerRadius * 2 + (root.opened ? 0 : Config.hoverPadX * 2)
        height: root.targetHeight + (root.opened ? 0 : Config.hoverPadY)

        // One handler rather than one per half. Two would have to be enabled
        // and disabled as the notch opens, and the handover drops an exit on
        // the floor — which reads as the notch closing in your face.
        HoverHandler {
            id: pointer

            // The whole point: see the hover without consuming it.
            blocking: false

            // Routing is guarded by `opened` in both handlers, and it has to
            // be in both. A panel pinned open by IPC is already open when the
            // pointer arrives, so an unguarded enter would route on whatever
            // happened to be under it and swap the panel out from under you —
            // the launcher becoming the control centre because you reached
            // across it.
            onHoveredChanged: {
                if (pointer.hovered) {
                    collapseTimer.stop();
                    root.peeking = false;
                    if (!root.opened)
                        root.hoverTarget = root.targetAt(pointer.point.position.x);
                } else {
                    collapseTimer.restart();
                }
            }

            // Once a panel is up, moving across it must not swap it for
            // whatever third is under the pointer now.
            onPointChanged: {
                if (pointer.hovered && !root.opened)
                    root.hoverTarget = root.targetAt(pointer.point.position.x);
            }
        }

        // Right-click anywhere pins whichever panel you are looking at. Left
        // clicks are left alone so they reach the controls underneath.
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: eventPoint => NotchState.toggle(root.opened ? root.openTarget : root.targetAt(eventPoint.position.x))
        }

        // ── Shape ────────────────────────────────────────────────────────

        // Declared before the shape so it falls behind it. It draws the
        // shape's own silhouette a second time underneath — identical pixels
        // in the same place, so all you see of it is what spills past the
        // edges — which is what lets the shadow follow the flared corners
        // exactly rather than being a rounded rectangle approximating them.
        //
        // autoPaddingEnabled lets the blur render outside the item's bounds;
        // hitArea does not clip, so it reaches the window's own edge, which
        // is why the window grew by shadowMargin.
        MultiEffect {
            anchors.fill: shape
            source: shape

            shadowEnabled: true
            shadowColor: "black"
            shadowOpacity: Config.shadowOpacity
            shadowBlur: 1
            blurMax: Config.shadowBlur
            shadowVerticalOffset: Config.shadowY
            autoPaddingEnabled: true
        }

        NotchShape {
            id: shape

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0

            // Required for the effect above to have something to sample.
            layer.enabled: true

            bodyWidth: root.targetWidth
            bodyHeight: root.targetHeight
            bottomRadius: Config.bottomRadius
            cornerRadius: Config.cornerRadius
            color: Config.surface

            Behavior on bodyWidth {
                NumberAnimation {
                    duration: Config.growDuration
                    easing.type: root.opened ? Easing.OutBack : Easing.OutCubic
                    easing.overshoot: Config.overshoot
                }
            }

            Behavior on bodyHeight {
                NumberAnimation {
                    duration: Config.growDuration
                    easing.type: root.opened ? Easing.OutBack : Easing.OutCubic
                    easing.overshoot: Config.overshoot
                }
            }
        }

        // ── Content ──────────────────────────────────────────────────────

        // Animated clip window over the body. Children inside are given fixed
        // sizes so they are translated as the notch grows, never re-laid-out.
        Item {
            id: contentClip

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: shape.bodyWidth
            height: shape.bodyHeight
            clip: true

            // Now playing — the right end of the closed bar.
            Loader {
                id: barMedia

                x: root.barMediaX
                anchors.verticalCenter: parent.verticalCenter
                width: Config.barMediaWidth
                height: Config.barHeight

                // Stays loaded while a player exists, so pausing and resuming
                // never rebuilds it.
                active: Media.hasPlayer
                asynchronous: true

                opacity: root.mode === "bar" ? 1 : 0
                visible: opacity > 0

                sourceComponent: CollapsedMedia {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: peek

                anchors.centerIn: parent
                width: Config.peekWidth - 32
                height: Config.peekHeight - 20

                // Built on the first notification and kept afterwards.
                active: Notifs.latest !== null
                asynchronous: true

                opacity: root.mode === "notify" ? 1 : 0
                visible: opacity > 0

                sourceComponent: NotificationPeek {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: mediaPanel

                anchors.centerIn: parent
                width: Config.mediaPanelWidth
                height: Config.mediaPanelHeight

                // Deliberately not active at startup. See preloadTimer below.
                active: false
                asynchronous: true

                opacity: root.mode === "media" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: MediaPanel {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: launcher

                anchors.centerIn: parent
                width: Config.launcherWidth
                height: Config.launcherHeight

                // Not preloaded with the others: it builds a list of every
                // desktop entry on the machine, and unlike the panels behind
                // the bar it is never a hair-trigger away from being shown.
                active: false
                asynchronous: true

                opacity: root.mode === "launcher" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: LauncherPanel {
                    onDismissed: NotchState.close()
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: notifications

                anchors.centerIn: parent
                width: Config.notifPanelWidth
                height: Config.notifPanelHeight

                // Built with the others: it is cheap, and the history it
                // shows exists whether anyone is looking or not.
                active: false
                asynchronous: true

                opacity: root.mode === "notifications" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: NotificationCenter {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: powerMenu

                anchors.centerIn: parent
                width: Config.powerMenuWidth
                height: Config.powerMenuHeight

                active: false
                asynchronous: true

                opacity: root.mode === "power" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: PowerMenu {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: wallpaper

                anchors.centerIn: parent
                width: Config.wallpaperWidth
                height: Config.wallpaperHeight

                // Built on demand like the launcher rather than with the
                // panels behind the bar: it decodes a directory of pictures,
                // and nothing here is ever a hair-trigger away from opening
                // it by accident.
                active: false
                asynchronous: true

                opacity: root.mode === "wallpaper" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: WallpaperPanel {
                    onDismissed: NotchState.close()
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: theme

                anchors.centerIn: parent
                width: Config.themePanelWidth
                height: Config.themePanelHeight

                // On demand, like the launcher and the wallpaper picker: it
                // is reached by keybind rather than by hovering the bar, so
                // it is never a hair-trigger away from being needed.
                active: false
                asynchronous: true

                opacity: root.mode === "theme" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: ThemePanel {
                    onDismissed: NotchState.close()
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            Loader {
                id: controlCentre

                anchors.centerIn: parent
                width: Config.ccWidth
                height: Config.ccHeight

                active: false
                asynchronous: true

                opacity: root.mode === "control" && status === Loader.Ready ? 1 : 0
                visible: opacity > 0

                sourceComponent: ControlCenter {}

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            // Declared after the panels so they draw over whichever state's
            // content is on screen while they fly across it.
            NotchArt {
                morph: root.mediaMorph

                collapsedX: barMedia.x + (root.barItem ? root.barItem.artX : 0)
                collapsedY: barMedia.y + (root.barItem ? root.barItem.artY : 0)
                expandedX: mediaPanel.x + (root.mediaItem ? root.mediaItem.artX : 0)
                expandedY: mediaPanel.y + (root.mediaItem ? root.mediaItem.artY : 0)

                // Only the two states it belongs to. Everything else owns the
                // whole body while it is up.
                opacity: root.mode === "bar" || root.mode === "media" ? 1 : 0
                visible: opacity > 0 && Media.hasPlayer

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            NotchTitle {
                morph: root.mediaMorph

                collapsedX: barMedia.x + (root.barItem ? root.barItem.titleX : 0)
                collapsedY: barMedia.y + (root.barItem ? root.barItem.titleY : 0)
                expandedX: mediaPanel.x + (root.mediaItem ? root.mediaItem.titleX : 0)
                expandedY: mediaPanel.y + (root.mediaItem ? root.mediaItem.titleY : 0)

                collapsedWidth: root.barItem ? root.barItem.titleWidth : 0
                expandedWidth: root.mediaItem ? root.mediaItem.titleWidth : 0

                opacity: root.mode === "bar" || root.mode === "media" ? 1 : 0
                visible: opacity > 0 && Media.hasPlayer

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            NotchVisualizer {
                morph: root.mediaMorph

                collapsedX: barMedia.x + (root.barItem ? root.barItem.visualiserX : 0)
                collapsedY: barMedia.y + (root.barItem ? root.barItem.visualiserY : 0)
                expandedX: mediaPanel.x + (root.mediaItem ? root.mediaItem.visualiserX : 0)
                expandedY: mediaPanel.y + (root.mediaItem ? root.mediaItem.visualiserY : 0)

                opacity: root.mode === "bar" || root.mode === "media" ? 1 : 0
                visible: opacity > 0 && Media.hasPlayer

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            NotchBell {
                id: bell

                morph: root.notifMorph

                collapsedX: root.barBellX
                collapsedY: (contentClip.height - height) / 2
                expandedX: notifications.x + (root.notifItem ? root.notifItem.bellX : 0)
                expandedY: notifications.y + (root.notifItem ? root.notifItem.bellY : 0)

                // The closed bar and the panel it opens, and nothing else —
                // and only while there is something waiting. Clearing the
                // list with the panel open takes the bell with it, which is
                // the same thing it says everywhere else.
                opacity: root.showBell && (root.mode === "bar" || root.mode === "idle" || root.mode === "notifications") ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }

            // Declared last so it draws over whichever state's content is on
            // screen while it flies across it.
            NotchClock {
                id: clock

                morph: root.clockMorph

                // Sits after the bell, measured from the left edge. There is
                // no centred case any more — the clock is never alone in the
                // bar.
                collapsedX: root.barClockX
                collapsedY: (contentClip.height - clock.height) / 2

                // The control centre is a fixed-size child of this clip, so its
                // own position plus the clock offset within it is the landing
                // point. Before the preload finishes there is nowhere to fly to,
                // but nothing is open yet either, so the fallback is never seen.
                expandedX: controlCentre.x + (root.controlItem ? root.controlItem.clockX : 0)
                expandedY: controlCentre.y + (root.controlItem ? root.controlItem.clockY : 0)

                // The media panel and notification peeks own the whole body while
                // they are up; the clock is not part of either.
                opacity: root.mode === "media" || root.mode === "notify" || root.mode === "launcher" || root.mode === "notifications" || root.mode === "power" || root.mode === "wallpaper" || root.mode === "theme" ? 0 : 1
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.fadeDuration
                    }
                }
            }
        }
    }

    mask: Region {
        item: hitArea
    }

    // Build both panels in the background once the first frame is safely on
    // screen. By the time anyone hovers, opening either is a visibility
    // change rather than a construction.
    Timer {
        id: preloadTimer
        interval: Config.preloadDelay
        running: true
        onTriggered: {
            mediaPanel.active = true;
            controlCentre.active = true;
            notifications.active = true;
            powerMenu.active = true;
        }
    }

    // If someone opens the notch before the preload timer fires, build them
    // now rather than showing an empty box.
    onOpenedChanged: {
        if (!root.opened)
            return;
        mediaPanel.active = true;
        controlCentre.active = true;
        notifications.active = true;
        powerMenu.active = true;
    }

    onModeChanged: {
        if (root.mode === "launcher")
            launcher.active = true;
        if (root.mode === "wallpaper")
            wallpaper.active = true;
        if (root.mode === "theme")
            theme.active = true;
    }
}
