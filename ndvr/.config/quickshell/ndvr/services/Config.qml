pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    // ── Behaviour ────────────────────────────────────────────────────────
    // Claim org.freedesktop.Notifications. Turn this off if you still run
    // dunst/mako/swaync — only one process can own the name.
    readonly property bool actAsNotificationDaemon: true

    // Delay before the notch collapses after the pointer leaves. Stops the
    // notch flickering when you cross it on the way somewhere else.
    readonly property int collapseDelay: 140

    // How long a notification peek stays up.
    readonly property int peekDuration: 4500

    // Wait this long after startup before building the expanded panel in the
    // background. Long enough that the first frame is already on screen.
    readonly property int preloadDelay: 1500

    // ── Geometry ─────────────────────────────────────────────────────────
    // The "body" is the black rectangle. Total painted width is always
    // body + cornerRadius * 2, because the flared corners sit outside it.

    // Closed, with a player: now playing on the left, the time on the right.
    //
    // The bar is not this wide — it hugs whatever is actually in it. This is
    // only the widest it can get, which is what the window has to be built
    // for. See Notch.qml's targetWidth.
    readonly property real barWidth: 296
    readonly property real barHeight: 36

    // The box CollapsedMedia is laid out in, not what it occupies: the row is
    // packed to its left and the slack left over. Fixed rather than derived
    // from barWidth, so the strip is translated as the bar grows instead of
    // being re-laid-out every frame. Wide enough for art + a capped title +
    // visualiser, which is the worst case.
    //
    // Because now playing sits at the right end of the bar, Notch places it
    // by its *content* width rather than this one — see barMediaX — so the
    // slack falls outside the notch and gets clipped rather than sitting
    // between the title and the padding.
    readonly property real barMediaWidth: 166
    readonly property real barPadX: 14
    readonly property real barSpacing: 8

    // Between the clock and the now-playing group after it. Wider than
    // barSpacing so the two read as two things rather than one run-on row,
    // and no wider than it takes to say that.
    readonly property real barGap: 20

    // Where a long title gets truncated, counted in characters rather than
    // pixels: ten of them, then an ellipsis. The bar is a glance, not a place
    // to read a track name from end to end — and the shorter this is, the
    // less the whole bar moves when the track changes.
    //
    // CollapsedMedia turns this into the width the title elides against, by
    // measuring the ten characters it is willing to show. A pixel width would
    // have been simpler, but "ten characters" is the thing actually being
    // asked for, and ten characters is not a fixed width in a proportional
    // font.
    readonly property int barTitleChars: 10

    // The two ends of the art and title animations. Like the clock, each is
    // one object that grows rather than two that cross-fade, so both ends
    // live here instead of in either component.
    readonly property real barArtSize: 20
    readonly property real barArtRadius: 5
    readonly property real barTitleSize: 12

    // Sized to fill the panel's row rather than float inside it: at 112 the
    // art was centred in a 144-tall row, so it sat 36px from the panel edge
    // while every other panel's content starts at ccPadX.
    readonly property real panelArtSize: 144
    readonly property real panelArtRadius: 18
    readonly property real panelTitleSize: 17

    // The visualiser makes the same journey, ending at the far right of the
    // title. Its width is the Row's natural one either end; only the bars get
    // taller, to suit the larger title it sits beside.
    readonly property real visualiserWidth: 20
    readonly property real barVisualiserHeight: 12
    readonly property real panelVisualiserHeight: 18

    // The bell at the left end of the closed bar, and the gap between it and
    // the time after it. Hover zones are not configured — they are derived
    // from where these actually end up, in Notch.qml's targetAt.
    readonly property real barBellSize: 15
    readonly property real barBellGap: 18

    // The other end of the bell's journey: the right of the notification
    // centre's heading.
    readonly property real panelBellSize: 18

    // Closed, with nothing playing: just the time, in a pill that hugs it.
    // There is no idleWidth — the width comes from the clock plus barPadX.
    readonly property real idleHeight: 32

    readonly property real peekWidth: 400
    readonly property real peekHeight: 78

    // The two open panels. Hovering the left of the bar opens the first,
    // hovering the time opens the second.
    readonly property real mediaPanelWidth: 460
    readonly property real mediaPanelHeight: 184

    // The control centre: a status header over a body of controls.
    readonly property real ccWidth: 480
    readonly property real ccHeight: 452

    // The window is built once at the size of the largest state and never
    // resized, so it needs to know what that is.
    readonly property real maxWidth: Math.max(mediaPanelWidth, ccWidth, peekWidth, barWidth, launcherWidth, notifPanelWidth, powerMenuWidth, wallpaperWidth, themePanelWidth)
    readonly property real maxHeight: Math.max(mediaPanelHeight, ccHeight, peekHeight, barHeight, launcherHeight, notifPanelHeight, powerMenuHeight, wallpaperHeight, themePanelHeight)

    readonly property real bottomRadius: 18
    readonly property real cornerRadius: 14

    // The two ends of the clock's animation. It is one object in both states,
    // so these live here rather than in either component.
    readonly property real clockSmall: 13
    readonly property real clockLarge: 40

    // ── Calendar ─────────────────────────────────────────────────────────
    // The day strip under the clock. Just tall enough for the two rows —
    // the space around it comes from the rail, not from padding in here.
    //
    // The month is a label on the row, not a second headline under the
    // clock. At 24 it was competing with the time for the top-left corner
    // and crowding a 10px weekday row from six pixels away; at 17 the
    // hierarchy reads time, then dates, then the month naming them.
    readonly property real calHeight: 36
    readonly property real calMonthSize: 17
    readonly property real calWeekdaySize: 10
    readonly property real calDateSize: 14

    // Between the weekday letter and the date under it.
    readonly property real calRowGap: 5

    // One day column. Fixed rather than derived, because the strip scrolls
    // under its viewport instead of dividing it up.
    readonly property real calCellWidth: 38

    // Between the month label's box and the first day column. Small on
    // purpose: the first date is centred in its cell, which already puts
    // ~12px of air after this gap before any glyph appears.
    readonly property real calGap: 6

    // The month label is given a fixed width rather than its natural one.
    // It has to be, because its text follows the scrolled window: sizing the
    // strip from it while it reads the strip back is a binding loop, and a
    // label that resized on "Aug" → "Sep" would shunt the days sideways.
    //
    // Measured, not guessed: the widest three-letter month at this size is
    // "May" at 34.6px. Anything past that is dead space that reads as a gap.
    // Re-measure this if calMonthSize changes — it was 50 while the month
    // was set at 24.
    readonly property real calMonthWidth: 36

    // Applied at both edges. Under one day column, because the viewport is
    // narrow enough now that a wider ramp would eat most of what it shows.
    readonly property real calFade: 30

    // How far one wheel notch moves the window, and how quickly it settles.
    readonly property real calScrollStep: 0.4
    readonly property int calScrollDuration: 140

    // ── Launcher ─────────────────────────────────────────────────────────
    // The largest state, and so the one that sets the window size.
    readonly property real launcherWidth: 620
    readonly property real launcherHeight: 440

    readonly property real searchHeight: 40
    readonly property real appRowHeight: 46
    readonly property real appIconSize: 28

    // ── Power menu ───────────────────────────────────────────────────────
    // Four actions in a 2x2 rather than a row of four. A row made the panel
    // wider than the control centre for four words, and put Lock — the one
    // you actually press — at the far end of a long reach; the square is
    // roughly the size of the thing it is, and no corner is far from any
    // other.
    //
    // The buttons stretch to fill the panel, so this is what they settle at
    // rather than a width anything is pinned to. The panel is derived from
    // it so the two cannot drift apart.
    readonly property real powerButtonWidth: 125
    readonly property real powerButtonHeight: 86
    readonly property real powerButtonGap: 10
    readonly property real powerIconSize: 24

    readonly property real powerMenuWidth: powerButtonWidth * 2 + powerButtonGap + ccPadX * 2

    // Two rows of buttons, the gap between them, and the panel's own bottom
    // inset, under the heading.
    readonly property real powerMenuHeight: panelHeadingHeight + panelHeadingGap + powerButtonHeight * 2 + powerButtonGap + ccPadX

    // What each button runs. Here rather than in code, so a different
    // session, init or locker is a config change.
    readonly property var shutdownCommand: ["systemctl", "poweroff"]
    readonly property var rebootCommand: ["systemctl", "reboot"]
    // Log out is a Hyprland dispatcher rather than a command: Power sends it
    // straight down Hyprland's request socket, so there is no hyprctl to
    // spawn and a failure comes back to us instead of into the void.
    //
    // Two spellings, because Hyprland has two config languages and the
    // dispatcher syntax differs between them. Power picks by asking which is
    // in use rather than assuming, so this config works on either.
    readonly property string logoutDispatch: "exit"
    readonly property string logoutDispatchLua: "hl.dsp.exit()"

    // Runs the locker directly rather than signalling logind with
    // `loginctl lock-session`. That is the tidier call — it lets whatever is
    // registered to handle the lock do it — but nothing is registered unless
    // hypridle is running, so on a machine without it the button did nothing
    // at all and said nothing about why.
    //
    // Guarded the same way hypridle's own `lock_cmd` is, so a second press
    // while the screen is already locked doesn't stack a second locker on
    // top of the first.
    readonly property var lockCommand: ["sh", "-c", "pidof hyprlock || hyprlock"]

    // ── Wallpaper ────────────────────────────────────────────────────────
    // Where the pictures are, and the link the compositor's wallpaper daemon
    // reads. Both are paths rather than anything cleverer, because the link
    // is what `install.sh` sets up and what survives this shell not running.
    readonly property string wallpaperDir: `${Quickshell.env("HOME")}/.config/ndvr/wallpapers`
    readonly property string wallpaperLink: `${Quickshell.env("HOME")}/.config/wallpaper`

    // Repointing the link is not enough on its own. hyprpaper reads it once
    // at startup and 0.8 has no runtime IPC for changing it, so the only way
    // to make it look again is to start it again — which is quick enough that
    // there is nothing to see. Here rather than in code, so a different
    // wallpaper daemon is a config change: swww and wpaperd both take a
    // set-image command instead, and an empty list means "just move the link,
    // something else is watching it".
    readonly property var wallpaperApplyCommand: ["sh", "-c", "pkill -x hyprpaper; exec hyprpaper"]

    readonly property real wallpaperWidth: stripPanelWidth
    readonly property real wallpaperHeight: stripPanelHeight

    // ── Notification centre ──────────────────────────────────────────────
    readonly property real notifPanelWidth: 460
    readonly property real notifPanelHeight: 400
    readonly property real notifRowHeight: 66
    readonly property real notifIconSize: 34

    // The action buttons under a notification. Only rows whose sender offered
    // actions have them, so this height is added to notifRowHeight rather
    // than folded into it — a panel of notifications that can't be acted on
    // shouldn't be a panel of empty space.
    readonly property real notifActionHeight: 25
    readonly property real notifActionGap: 8
    readonly property real notifActionSpacing: 6
    readonly property real notifActionPadX: 11

    // Where a wordy action label gets truncated. Senders write these, and
    // "Mark all as read and archive" is not going to fit beside two others.
    readonly property real notifActionMaxWidth: 150

    // ── Strip panels ─────────────────────────────────────────────────────
    // The shape the wallpaper picker and the theme picker both take: a
    // heading, a row of tiles sliding under a fixed window, and a caption
    // naming whichever is on the centre line. They are the same kind of
    // thing — pick one of a handful by looking at it — so they are one set
    // of numbers rather than two that drift.
    //
    // As wide as the launcher on purpose: another panel you pick one item
    // out of, and two panels differing by twenty pixels look like a mistake.
    readonly property real stripPanelWidth: 620

    // 16:9. Every wallpaper is, and a strip whose tiles crop differently
    // reads as a jumble rather than a row; the theme previews take the same
    // frame so the two panels are recognisably the same object.
    readonly property real stripTileWidth: 240
    readonly property real stripTileHeight: 135
    readonly property real stripTileGap: 14
    readonly property real stripTileRadius: 12

    // The neighbours either side, knocked back so the centred one is
    // obviously the one you are choosing.
    readonly property real stripTileDim: 0.38

    // How far the strip dissolves into the panel at each end, and how long a
    // tile takes to slide to the middle.
    readonly property real stripFade: 44
    readonly property int stripSlideDuration: 260

    // Between the tiles and the caption under them, and what that line of
    // 12px text comes to — measured, like panelHeadingHeight, because the
    // panel adds itself up in here where the font cannot be asked.
    readonly property real stripCaptionGap: 12
    readonly property real stripCaptionHeight: 15

    readonly property real stripPanelHeight: panelHeadingHeight + panelHeadingGap + stripTileHeight + stripCaptionGap + stripCaptionHeight + ccPadX

    // ── Panel headings ───────────────────────────────────────────────────
    // What the notification centre, the power menu and the wallpaper picker
    // all wear: a title, a hairline under it, and the same air above the
    // content below. They are the same kind of object, so they are the same
    // shape — see PanelHeading.qml.
    readonly property real panelHeadingSize: 14
    readonly property real panelRuleGap: 14
    readonly property real panelHeadingGap: 8

    // What PanelHeading comes to: ccPadX + the label + panelRuleGap + the
    // rule. Measured rather than guessed — the label is 17px tall at
    // panelHeadingSize — because panels that size themselves to their
    // contents have to add it up in here, where the font is not available to
    // ask. Re-measure if panelHeadingSize changes.
    readonly property real panelHeadingHeight: ccPadX + 17 + panelRuleGap + 1

    // ── Theme picker ─────────────────────────────────────────────────────
    // Built as a strip panel, exactly like the wallpaper picker: you pick a
    // palette by looking at it, which is the same job.
    readonly property real themePanelWidth: stripPanelWidth
    readonly property real themePanelHeight: stripPanelHeight

    // The one number the theme strip does not borrow from the wallpaper one.
    // A dimmed photograph is still a photograph, but a palette dimmed to
    // stripTileDim is a grey blob — and the colours are the entire content of
    // the tile, so knocking the neighbours back that far hides the thing you
    // are being asked to choose between. Enough to say "not this one",
    // not so much that you can't see what "this one" would be.
    readonly property real themeTileDim: 0.72

    // ── Control centre ───────────────────────────────────────────────────
    // Inset used by every page in the panel, and by the clock it holds.
    readonly property real ccPadX: 20

    // Under the clock, and under the day strip below it. The header is the
    // densest part of the panel — three type sizes inside ninety pixels —
    // so it gets more air than the body, where the tiles carry their own.
    readonly property real ccClockGap: 20
    readonly property real ccRuleGap: 22

    // The vitals block in the header, sized by its readings rather than its
    // bars — "8.4GB" is several times wider than the hairline it sits over.
    // Three of them: cpu, temperature, memory. Battery is not here — it
    // moves over hours rather than seconds, and lives with the power profile.
    //
    // Width only. Its height is taken from the day strip beside it, so the
    // header's two columns end on the same line however tall either gets.
    readonly property real statsWidth: 114

    // Between the time cluster and the vitals beside it.
    readonly property real ccGap: 24
    // Matches SliderRow's track, so the two kinds of bar in the panel read
    // as the same object turned on its side.
    readonly property real statBarWidth: 4

    // One cadence per metric. Load is bursty and wants a second; a CPU's
    // thermal mass means its temperature cannot meaningfully move that fast;
    // memory drifts slowly enough that a per-second reading is just noise.
    readonly property int cpuInterval: 2000
    readonly property int tempInterval: 2500
    readonly property int memInterval: 5000

    // The temperature range worth drawing — a CPU never sits near zero, so a
    // bar starting there would barely move.
    readonly property real tempMin: 30
    readonly property real tempMax: 95

    // Above this the temperature bar goes red.
    readonly property real tempHot: 80

    // Sliding between the main page and a device list.
    readonly property int pageDuration: 260

    // One row in a device list, and the air between a row's hover lozenge and
    // what is written inside it — the device lists', the notification
    // centre's, wherever a list has rows. The padding is inside the row
    // rather than outside: the lozenge is exactly the width of the list, and
    // the content sits in from its edge.
    readonly property real rowHeight: 42
    readonly property real rowPadX: 10

    // Shared by every row lozenge — the launcher's, the device lists', the
    // back control's. See RowHighlight.qml.
    readonly property real rowRadius: 10

    // The back control is shorter than the header row it sits in, so its
    // lozenge has air above and below rather than running into the rule
    // underneath it and the panel's edge above.
    readonly property real backHeight: 30

    // ── Control centre tiles ─────────────────────────────────────────────
    readonly property real tileHeight: 54
    readonly property real tileRadius: 13
    readonly property real tileGap: 10
    readonly property real tilePadX: 12

    // The badge behind the wifi/bluetooth mark. It is what carries on/off,
    // so it is round and filled rather than being a tint on the whole tile.
    readonly property real tileBadge: 28

    // The on/off switch at the top of a device page: the track, and the air
    // between the knob and the track's edge. The knob's size is what is left
    // over, so it stays round whatever the track is.
    readonly property real switchWidth: 40
    readonly property real switchHeight: 22
    readonly property real switchInset: 2

    // Quicker than the segmented control's thumb: a shorter journey, and a
    // switch should feel like it snaps.
    readonly property int switchDuration: 180

    // The power-profile picker, which shares a row with the battery reading.
    readonly property real powerPickerWidth: 260
    readonly property real segmentHeight: 32
    readonly property real segmentInset: 3
    readonly property int segmentDuration: 200

    // Extra invisible hit area around the collapsed pill so it is easy to
    // hit by throwing the pointer at the top of the screen.
    readonly property real hoverPadX: 20
    readonly property real hoverPadY: 6

    // ── Shadow ───────────────────────────────────────────────────────────
    // The notch casts onto whatever is behind it. Subtle on purpose: enough
    // to lift it off the wallpaper and give the flared corners something to
    // sit against, not enough to read as a card floating over the screen —
    // it is still pretending to be part of the bezel.
    readonly property real shadowBlur: 28
    readonly property real shadowOpacity: 0.30
    readonly property real shadowY: 5

    // The window has to be big enough to draw the shadow into. It is sized
    // once for the largest panel, and a shadow running past the window edge
    // is a shadow with a straight line cut through it — there was 20px of
    // slack at the sides and 12px underneath, against a blur that reaches
    // roughly its own radius plus however far it is pushed down.
    readonly property real shadowMargin: shadowBlur + shadowY

    // ── Motion ───────────────────────────────────────────────────────────
    readonly property int growDuration: 340
    readonly property int fadeDuration: 160

    // How far the notch springs past its destination on the way open. Only
    // on the way open: Notch drops to a plain ease-out for anything closing
    // or merely resizing, because overshooting on the way *out* is a wobble,
    // not a spring.
    readonly property real overshoot: 1.1

    // A press acknowledging itself: the scale dip under the pointer, on
    // every tile, chip, button and switch. Short enough to have finished by
    // the time you notice you pressed.
    readonly property int pressDuration: 90

    // A row lozenge arriving under the pointer. Deliberately quicker than
    // fadeDuration because it follows the pointer — a highlight easing in
    // over a sixth of a second reads as the pointer being slow rather than
    // the highlight being smooth.
    readonly property int highlightDuration: 90

    // ── Palette ──────────────────────────────────────────────────────────
    // Six roles, and every colour in the shell is one of them. They come from
    // whichever theme is selected — see Themes.qml, which is also the only
    // place to touch to add another.
    //
    // Nothing reads Themes directly except the picker: the rest of the shell
    // asks Config for a role, the same as it always did, and re-colours
    // itself the moment the selection changes because these are bindings.
    //
    // `color` rather than `string`, so a component can take a role apart —
    // the two places that need something part-way between a surface and its
    // contents build it from `text` at low alpha, which needs the channels.
    readonly property color surface: Themes.current.surface
    readonly property color text: Themes.current.text
    readonly property color textDim: Themes.current.textDim
    readonly property color hairline: Themes.current.hairline
    readonly property color accent: Themes.current.accent
    readonly property color urgent: Themes.current.urgent

    // A wash of the foreground over whatever is behind it. Lightens a dark
    // theme and darkens a light one, because it is the theme's own text
    // colour doing the washing — so "one step up from the backdrop" holds
    // without anything having to know which kind of theme is on.
    function raise(alpha: real): var {
        return Qt.rgba(text.r, text.g, text.b, alpha);
    }

    // The panel's own colour at a given alpha, for the gradients that
    // dissolve a scrolling strip into its edges — the day strip and the
    // wallpaper strip. Built from `surface` rather than ramping to
    // Qt.transparent, which is a transparent *white*: on a dark theme that
    // washes the content out before it hides it, and on a light one it is
    // not a fade at all.
    function fade(alpha: real): var {
        return Qt.rgba(surface.r, surface.g, surface.b, alpha);
    }

    // Rec. 709 relative luminance, which is what "is this colour light or
    // dark" means when you have to answer it arithmetically.
    function luminance(c: var): real {
        return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
    }

    // Whatever is drawn *on* the accent: a selected segment's label, the mark
    // in a lit badge, the switch knob, selected text in the launcher.
    //
    // Not `text`, which is only right by luck. A theme is free to pair a
    // light accent with light text — Mocha does — or a dark accent with dark
    // text, as Latte does, and either way the thing on top disappears into
    // what it is sitting on. This picks whichever of the palette's two
    // extremes is further from the accent in luminance, so the answer stays
    // inside the theme rather than falling back to white.
    readonly property color onAccent: {
        const a = luminance(accent);
        return Math.abs(luminance(surface) - a) >= Math.abs(luminance(text) - a) ? surface : text;
    }

    readonly property string font: "Inter"
}
