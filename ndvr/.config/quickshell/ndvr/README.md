# notch

A NotchNook-style notch for Hyprland, built on Quickshell.

It sits flush against the top edge of every monitor as a small dark bar with
the time and now playing, joined on the left by a notification bell whenever
something is waiting. It peeks when a notification arrives, and opens on hover
into a panel depending on which part you aimed at: the bell opens the
notification centre, the time opens a control centre, and now playing opens
transport — the clock growing into place as it does. A keybind opens an
application launcher in the same notch.

# Todo

- Workspaces
- [x] Application launcher (toggleable by IPC)
- [ ] Control center (toggleable by IPC)
  - [x] Bluetooth
  - [x] Wifi
  - [x] Audio input/output devices
  - [x] Battery (power settings)
  - [x] Brightness
  - [ ] Tailscale (Nice to have)
- [x] Notification center (toggleable by IPC)
  - [x] Action buttons
  - [ ] Inline reply
- [x] Power menu panel (toggleable by IPC)
  - [x] Reboot
  - [x] Shutdown
  - [x] Lock
  - [x] logout
- [x] Wallpaper selector (toggleable by IPC)
- [x] Theme selector (toggleable by IPC)
  - [x] Catppuccin Mocha
  - [x] Catppuccin Latte

## Install

```sh
git clone <this> ~/.config/quickshell/ndvr
touch ~/.config/quickshell/ndvr/.qmlls.ini   # Quickshell fills this in
```

Start it once from your compositor, daemonized, with duplicate protection:

```
# hyprland.conf
exec-once = qs -c ndvr -d -n
```

Requirements: Quickshell 0.3+ (the control centre uses `Quickshell.Networking`
and `Quickshell.Bluetooth`), Qt 6.6+ with QtQuick.Shapes.

The power menu shells out to `systemctl` (shut down, restart) and `hyprlock`
(lock), and sends log out down Hyprland's own socket. All four are in
`services/Config.qml` if your session wants different ones — `lockCommand`
is the one most likely to need changing, and swapping in `swaylock` or
`gtklock` is a one-line edit.
Optional but used when present: PipeWire (volume, audio devices), UPower
(battery), NetworkManager (wifi), BlueZ (bluetooth), and `brightnessctl` on
`PATH` for the brightness slider — without it that row simply hides.

**Fonts**: the design assumes Inter. Change `Config.font` if you don't have
it — Qt will fall back to a default sans otherwise, which will look fine but
slightly wider.

**Wallpaper**: the picker shows what is in `~/.config/ndvr/wallpapers` and
points `~/.config/wallpaper` at whichever one you choose — the same link
`install.sh` creates. Nothing here draws the wallpaper; that is your
compositor's wallpaper daemon reading that link, and the shipped
`hyprpaper.conf` does exactly that. Because hyprpaper reads the link once at
startup and 0.8 has no runtime IPC for changing it, `Config` restarts it
after repointing the link. Running something else — swww, wpaperd — is a
one-line change to `wallpaperApplyCommand`, and an empty list means "just
move the link, something else is watching it".

**Chrome and anything built on it** (Electron apps, Chrome PWAs — a Teams
window run with `--app=`) will only use a notification daemon that advertises
both the `body` and `actions` capabilities. It asks once, when the browser
process starts, and never asks again: a Chrome that was already running when
this shell claimed the name — or one that started while `actionsSupported`
was off — draws its own notifications inside the browser window instead, and
nothing arrives here. The fix is to restart the browser, not the shell.

Two more things follow from Chrome being the sender. It writes the app icon
to a temp file and passes the path as `app_icon`, where the spec also allows
a themed icon name — `Notifs.appIconSource` takes either. And it puts the
origin, a blank line, and then the message in the body, which is why
`Notifs.bodyBlock` collapses blank lines: in a two-line row, a blank line
costs you the message.

**Notifications**: this config claims `org.freedesktop.Notifications`. If
anything else already owns that name — dunst, mako, swaync, or another shell
— this one silently gets nothing, and the notification centre stays empty
however many notifications arrive. Stop the other daemon, or set
`actAsNotificationDaemon: false` in `services/Config.qml` if you would rather
it didn't try. Quickshell retries automatically when the name is released, so
stopping the other one is enough; you don't have to restart this.

## Keybinds

```
# hyprland.conf
bind = SUPER, N, exec, qs -c ndvr ipc call notch toggle
bind = SUPER, C, exec, qs -c ndvr ipc call notch control
bind = SUPER, SPACE, exec, qs -c ndvr ipc call notch launcher
bind = SUPER, N, exec, qs -c ndvr ipc call notch notifications
bind = SUPER, W, exec, qs -c ndvr ipc call notch wallpaper
bind = SUPER, T, exec, qs -c ndvr ipc call notch theme
```

`toggle` and `open` act on the media panel, which is what a "show me the
notch" keybind almost always means; `control`/`openControl` and
`launcher`/`openLauncher`, `notifications`/`openNotifications`,
`power`/`openPower`, `wallpaper`/`openWallpaper` and `theme`/`openTheme` are
its pairs. `status` reports `closed` or the name of whichever panel is up.

The launcher and the wallpaper picker take the keyboard while they are open
(see below). `Escape` closes either, as does the same keybind again or
`qs -c ndvr ipc call notch close` — and for the launcher, launching
something.

Or, to avoid the process spawn entirely, uncomment the `GlobalShortcut`
block in `shell.qml` and use:

```
bind = SUPER, N, global, quickshell:notchToggle
```

Right-clicking the notch pins open whichever panel you are pointing at.

## Layout

```
shell.qml              Entry point. One Variants over screens, plus IPC.
Notch.qml              The window: state machine, input mask, animation.
components/
  NotchShape.qml       The silhouette, including the flared top corners.
  NotchClock.qml       The clock, which is always on screen.
  NotchArt.qml         The album art, bar to media panel.
  NotchTitle.qml       The track title, bar to media panel.
  NotchVisualizer.qml  The visualiser, bar to end of the title.
  BellMark.qml         The bell, hollow or filled, at any size.
  NotchBell.qml        That mark, bar to notification heading.
  CalendarStrip.qml    The sliding day strip under the clock.
  CollapsedMedia.qml   Closed-with-media strip.
  NotificationPeek.qml Notification peek.
  NotificationCenter.qml Open panel: notification history.
  NotificationRow.qml  One notification in that history.
  ActionChip.qml       One action button on a notification.
  PowerMenu.qml        Open panel: shut down, restart, log out, lock.
  PowerButton.qml      One action in that menu.
  MediaPanel.qml       Open panel: transport and scrubber.
  LauncherPanel.qml    Open panel: search field and application list.
  AppRow.qml           One application in the launcher list.
  PanelHeading.qml     Title, hairline, and room for what acts on the panel.
  ThemePanel.qml       Open panel: the palettes, as a strip.
  ThemeTile.qml        One palette in that strip, drawn in itself.
  WallpaperPanel.qml   Open panel: the wallpaper strip.
  WallpaperTile.qml    One wallpaper in that strip.
  ControlCenter.qml    Open panel: vitals, clock, day strip, radios, battery.
  StatBar.qml          One vertical meter, styled to match SliderRow.
  ToggleTile.qml       One control-centre toggle.
  SliderRow.qml        A labelled bar you can drag.
  SegmentedControl.qml One of a small set of mutually exclusive modes.
  PowerBlock.qml       Battery reading and power profile, in one card.
  DevicePage.qml       Frame for a device list: back, title, on/off.
  DeviceRow.qml        One line in a device list.
  WifiPage.qml         Visible networks.
  BtPage.qml           Paired bluetooth devices.
  RowHighlight.qml     The lozenge behind the row under the pointer.
  ToggleSwitch.qml     The on/off switch at the top of a device page.
  TileIcon.qml         Control-centre marks, drawn as geometry.
  MediaButton.qml      Transport controls, drawn as geometry not glyphs.
  Visualizer.qml       Bars that move while audio plays.
services/
  Config.qml           Sizes, timings, palette.
  NotchState.qml       Which panel is pinned open, driven by IPC.
  Media.qml            MPRIS player selection.
  Wifi.qml             WiFi state, reduced to what the tile shows.
  Bt.qml               Bluetooth state, ditto.
  Audio.qml            Pipewire devices, volume, and switching between them.
  Brightness.qml       Backlight, via brightnessctl.
  Apps.qml             Desktop entries, and the search over them.
  Wallpaper.qml        The pictures on disk, and the link that names one.
  Themes.qml           The palettes, and which one is on.
  SysMon.qml           CPU load, CPU temperature and memory use.
  Power.qml            Power profiles, from power-profiles-daemon.
  Battery.qml          Charge, and one line about what it is doing.
  Notifs.qml           Notification daemon, history buffer and actions.
  Time.qml             One clock for the whole shell.
```

## Why it's built this way

**The window never resizes.** It is created once at the size of the largest
state and stays there, transparent, with an input mask restricting clicks to
the notch itself. Animating a layer-shell surface's size means renegotiating
geometry with the compositor on every frame. Animating a `Shape` inside a
fixed surface does not.

**The input mask follows target geometry, not animated geometry.** `hitArea`
snaps to the size the notch is heading towards, so the mask is committed
twice per interaction instead of sixty times a second. It also means the
pointer is captured by the full expanded area the instant you hover, which
is what keeps the notch open while you move into it.

**Hover is tracked on an ancestor, not a sibling.** The shape and the content
live *inside* `hitArea`, and that nesting is the whole trick: a `HoverHandler`
reports on geometric containment in the item it is attached to, so an ancestor
stays hovered while the pointer is over any of its descendants. The tiles keep
their own hover effects and the notch still knows the pointer is inside it.

As a sibling this cannot work either way round, and both failures are worth
remembering. Below the content — which is what a `MouseArea` there gave you —
the first tile the pointer crossed took the hover, the notch saw an exit and
collapsed out from under whatever you were reaching for. Raised above the
content instead, the notch kept the hover but the panel subtree never
received any, so nothing lit up.

There is no `MouseArea` on `hitArea`, and its `TapHandler` accepts only the
right button, so left presses fall straight through to the controls inside.
The collapse timer re-checks `hovered` before firing rather than trusting the
exit that started it.

**The closed bar hugs what is in it.** Its width is not a constant: it is
padding, plus whatever the now-playing group actually occupies, plus a gap,
plus the clock's own width. Sizing it for a worst-case title instead left a
short one like "Hearts" sitting in front of ~120px of nothing before the
clock. `CollapsedMedia` is still *allotted* a fixed, generous width so its
layout never has to reflow — it just reports what it used, and the notch
sizes itself to that.

The gap between the now-playing group and the clock is its own value rather
than the spacing used inside the group, so the two read as two things rather
than one run-on row. Nothing in this feeds back: the strip's allocation and
the clock's width are both independent of the bar's width, so there is no
loop.

**Content is fixed-size and translated, not resized.** Each state's content
sits at its natural size inside a clip rectangle that animates. Layouts run
once on state change rather than every frame of the animation.

**Every panel is inset by `ccPadX`.** One value, so the panels agree with
each other rather than each carrying its own literal. The media panel used to
be the exception twice over: it hardcoded the number, and its album art was
centred in a row taller than itself, so the art sat 36px from the panel edge
while every other panel's content started at 20. The art now fills the row —
which is why `panelArtSize` is what it is, rather than a size picked for its
own sake.

**Five things morph, and none of them are cross-faded.** The clock travels
between the bar and the control centre; the album art, the track title and
the visualiser travel between the bar and the media panel, the visualiser
ending at the far right of the title; the bell travels from the right of the
bar to the right of the notification centre's heading. All five work the same
way and for the same reason, described below for the clock — the thing you
aimed at should still be there when you arrive.

The consequence is that neither end owns them. `CollapsedMedia` and
`MediaPanel` both keep invisible stand-ins — of exactly the right size, in
exactly the right place — and report where the layout put them. In the panel
the visualiser's stand-in sits at the end of the title's row, so the title
elides before it rather than running underneath it. The art requests its
image at the larger of the two sizes, so growing into the panel neither
re-fetches nor goes soft on the way.

Only one visualiser exists now rather than one per state, so its animations
run in one place — and they are still bound to `isPlaying`, so a paused
player costs nothing wherever it happens to be.

**The bar's title is capped in characters, and applied as a width.**
`Config.barTitleChars` is ten, and `CollapsedMedia` measures what ten
characters of *this* title comes to before handing that width to the
stand-in — ten characters is not a fixed width in a proportional font, so
the cap is measured per track rather than guessed once. It has to arrive as
a width because the visible title is a single object that grows into the
media panel and elides against whatever width it has; truncating the string
instead would mean swapping the text mid-flight, halfway through the notch
opening.

The measuring `FontMetrics` takes `font: title.font` rather than repeating
the family, size and weight, and the binding reads `metrics.font` before
calling `advanceWidth`. That read is the whole trick: `advanceWidth` is a
call, and a call registers no dependency on the metrics behind it, so the
cap was measured once in whatever font the metrics had before the real one
was applied — Noto Sans at 16px, a third wider than the title it was
supposed to be measuring — and never corrected.

The bell splits the same way: `BellMark` is the drawing at whatever size it
is asked for, and `NotchBell` is the one that moves. The notification centre
holds an invisible `BellMark` at panel size, which is what makes the landing
exact. Its heading says just `Clear` rather than `Clear 5`, because the list
under it is what says how much there is to clear.

**The notch casts a shadow, and the window had to grow to hold it.** A
`MultiEffect` sits behind `NotchShape` with `source` pointed at it, drawing
the silhouette a second time underneath — identical pixels in the same
place, so all you ever see of it is what spills past the edges. Sourcing the
real shape rather than approximating it with a rounded rectangle is what
lets the shadow follow the flared top corners exactly.

`autoPaddingEnabled` lets the blur render outside the item's bounds and
`hitArea` doesn't clip, so it reaches as far as the window itself — which
was the problem. The window is sized once for the largest panel and had 20px
of slack at the sides and 12px underneath, against a blur that reaches
roughly its own radius plus however far it is pushed down. A shadow running
past the window edge is a shadow with a straight line cut through it, so
`implicitWidth`/`implicitHeight` now include `Config.shadowMargin`. The
extra is transparent and outside the input mask, so it costs only the space
it reserves.

The one real cost is that `layer.enabled` puts the shape through a texture,
and the shape animates its size — so that texture is reallocated for each
frame of a panel opening. At the largest state it is about 1.2MB, which is
nothing on hardware already driving two displays, but it is the reason to
think twice before layering anything else in here.

**Motion springs on the way in and settles on the way out.** `Easing.OutBack`
overshoots whichever direction it is given, so using it for both meant a
closing panel shrank past its mark and came back — a wobble rather than a
spring, and the one piece of motion here that drew attention to itself
rather than to what it was carrying. Every `Behavior` on the notch's size
and on the three morphs now picks `OutBack` when arriving and `OutCubic`
when leaving.

The test is the same expression that computes each target, not a blanket
"is anything open": switching straight from one panel to another has one
morph arriving while another leaves, and the two want opposite curves.

Durations all live in `Config`. `growDuration` for anything the notch's
shape does, `fadeDuration` for cross-fades, `pressDuration` for the scale
dip that acknowledges a press, and `highlightDuration` for a row lozenge
arriving under the pointer. The last two are the same 90ms and are still
two names, because they are two different things that would want to move
apart rather than together.

**The clock is one object, not two.** It is the only content that doesn't
belong to a state, so it isn't cross-faded like the rest — a small clock
fading out while a large one fades in reads as two clocks swapping places.
Instead `NotchClock.qml` interpolates a single `Text` between the bar and the
control centre. That panel keeps an invisible copy of the clock
(`clockGhost`) purely so the rest of it lays out normally and the flying
clock has an exact position to aim at; both endpoints are expressed against live
geometry, so the clock is correctly placed on every frame of the notch
growing underneath it. Position rides the `OutBack` overshoot with the shape,
but font size is clamped to 0..1 — text briefly larger than its final size
reads as a glitch rather than as momentum.

**The calendar is dates, not events.** `CalendarStrip.qml` derives everything
from `Time.now` and reads no calendar backend, so it costs one binding
re-evaluation a minute and has no D-Bus dependency. Today is the only column
that spells its weekday out — `THU` rather than `T` — which is what stops a
row of single letters reading as a wall of Ts and Ss.

**The calendar scrolls, it doesn't reflow.** A thirty-day window sits at a
fixed cell width and is offset so today lands on the viewport's centre line;
the days either side run off under a gradient at both edges. Only four or
five are ever visible, but the ones dissolving at the edges are what make it
read as a continuing calendar rather than a row that starts and stops.
Because the viewport can be any width, `ccWidth` is a free choice
rather than something that has to fit a whole week.

A wheel or a horizontal touchpad swipe anywhere on the band moves the window,
clamped so the first and last of the thirty days stop flush against the
edges rather than rubber-banding. The clamp is applied to the offset as well
as in the wheel handler, so a stored scroll can't strand the window
off-viewport if the panel is resized under it. Scroll resets whenever the
panel hides, so opening the notch always lands on today.

The month label names the day on the centre line rather than today, because
scrolled back into August a heading of "Sep" over a row of August dates is
simply wrong. That forces its width to be fixed: sizing the strip from the
label while the label reads the strip back is a binding loop, and a heading
that resized on "Aug" → "Sep" would shunt the days sideways as you scrolled.

**Which third you aimed at picks the panel.** The closed bar is three things
side by side — now playing, the time, the bell — and `targetAt()` turns the
entry position into `"media"`, `"control"` or `"notifications"`.

The boundaries are taken from where the clock and the bell actually sit,
halfway across the gap in front of each, rather than from configured zone
widths. Zone widths were what this used to do, and they drifted out of step
with the drawing the moment anything either side changed size — the clock's
right end ended up inside the bell's zone. Deriving them means the target is
wherever the thing is.

Routing only runs while the notch is closed, and that guard has to be on
*both* hover handlers — the one that fires on entry as well as the one that
fires on movement. A panel pinned open by IPC is already open when the
pointer arrives, so an unguarded entry routes on whatever happens to be
under it and swaps the panel out from under you: the launcher becoming the
control centre because you reached across it.

A pin beats a hover, not the other way round. With the precedence the other
way, pressing the launcher keybind while the pointer happened to be resting
on the notch did nothing at all — the hover kept winning. An explicit request
should outrank an accidental one.

This is one handler over the whole hit area, not one per third. Several would
have to be enabled and disabled as the notch opens, and the handover drops an
exit event on the floor — which reads as the notch closing in your face.

`showMedia` is `Media.hasPlayer`, not `isPlaying`: the media third has to be
a stable thing to aim at, and a paused track is exactly when you want the
transport controls. With no player at all there is no right third, so
everything past the bell opens the control centre.

**The closed bar reads bell, time, now playing.** The three sit in that
order left to right, and `Notch` states each position once — `barBellX`,
`barClockX`, `barMediaX` — rather than scattering them across the items that
use them, because the hover zones are read off exactly the same numbers the
elements are drawn at and the two must not drift.

The bell and the clock are measured from the left edge, which is a constant,
so neither moves while the notch grows underneath them. Now playing is the
one measured from the right, and it is expressed against live geometry
rather than the target width so it stays correctly placed for every frame of
that growth instead of jumping at the end of it — which is what the clock
and bell used to do from the other side.

Now playing is placed by its *content* width, not by the width of the box it
is loaded into. `CollapsedMedia` packs its row to the left of a generously
sized layout and leaves the slack after it, so anchoring the box to the
right edge would have put that slack between the title and the padding
instead of outside the notch where it is clipped away.

**Every colour in the shell is one of six roles, and they all come from the
selected theme.** `Themes.qml` is the catalogue — surface, text, textDim,
hairline, accent, urgent, plus a name and an id — and adding a palette is
appending one object to `all`. There is no second place to touch and nothing
to register. `Config`'s palette is bound to the selection, so the rest of the
shell asks `Config` for a role exactly as it always did and re-colours itself
the instant the choice changes; nothing but the picker reads `Themes`.

**Nothing assumes a dark theme, and that took three derived colours.** The
original palette was black-and-white-at-varying-opacity, so several places
had a light-on-dark assumption baked in as a literal:

- `Config.raise(alpha)` is a wash of the theme's *own* text colour over
  whatever is behind it, which lightens a dark theme and darkens a light one
  for free. The action chips on a notification use it: they must read as a
  step above both the bare panel and the hairline lozenge that appears under
  the pointer, and a hardcoded white was invisible on Latte.
- `Config.fade(alpha)` is the surface at decreasing alpha, for the gradients
  that dissolve the day strip and the wallpaper strip into their edges.
  Ramping to `Qt.transparent` is a ramp towards transparent *white*, which
  washes content out before it hides it — and on a light theme is not a fade
  at all.
- `Config.onAccent` is whatever is drawn *on* the accent: a selected
  segment's label, the mark in a lit badge, the switch knob, selected text in
  the launcher. It cannot be `text`, which is only ever right by luck — Mocha
  pairs a light accent with light text and Latte a dark accent with dark
  text, and both make the thing on top disappear. It picks whichever of
  `surface` and `text` is further from the accent in Rec. 709 luminance, so
  the answer stays inside the theme instead of falling back to white.

**The choice is state, not configuration, and lives under
`XDG_STATE_HOME`.** `~/.config/ndvr` is a symlink into the dotfiles repo on
a stow-managed setup like this one, so writing the theme there would dirty a
git tree every time anyone changed it. `~/.local/state/ndvr/theme` holds one
line — the theme's id — and `FileView` creates the directory itself. The
file is watched, so editing it by hand changes the theme; a missing file is
the ordinary first-run state and falls back to the first theme in the list.

One wrinkle worth knowing: a watch cannot be placed on a file that does not
exist, so creating that file externally for the very first time is not seen
until the next reload. Choosing a theme in the panel writes it through the
same `FileView`, so that path is never affected.

**The bell is only there when it has something to say.** `Notch.showBell` is
`Notifs.count > 0`, and nothing waiting is the ordinary state — a mark that
sits in the bar all day to report it is a mark you stop seeing. So the bar
closes up and earns the width back, and the bell means something when it
appears. It costs `barBellGap + barBellSize`, 33px, which the bar animates
like any other size change.

Everything the bell touches is expressed through `bellBlockWidth`, which is
zero when there is no bell: the bar's width, the clock's position, and the
hover zones all follow from that one property. The `targetAt` guard is the
exception that has to be written out — without a bell `barClockX` is just
the padding, so the leftmost sliver of the bar, hover pad included, would
still open a notification centre nothing had pointed you at.

The trade is that **the notification centre has no hover target when the
list is empty**, which is the point: there is nothing to peek at. It is
still a keybind away, and that is the only route to the history of what you
have already dismissed.

`BellMark` is always the solid, bright bell now. It used to draw itself
hollow and dim for an empty list — the whole of what a number beside it had
been saying — but that state became unreachable the moment the bell stopped
appearing for an empty one, and it was actively wrong on the way out:
clearing the panel had the mark change shape and colour as it faded rather
than simply going. `TileIcon.filled` stays, since the bell's outline is left
open along its base and closing it is what a hollow mark would need.

**Every list highlights a row the same way.** `RowHighlight.qml` is the
filled lozenge behind whatever the pointer is on — the launcher's rows, the
wifi and bluetooth rows, the notifications, the back control at the top of a
device page. Filled rather than a colour change on the text, so a mouse
hover and the launcher's keyboard selection can be the same mark and the
list still reads as a list. It animates over 90ms rather than
`fadeDuration`, because it follows the pointer: a highlight easing in over a
sixth of a second reads as the pointer being slow rather than the highlight
being smooth.

The device rows and the notification rows both used to do it differently — a
part-opacity rectangle that bled five pixels past the list on each side
while the content started at the lozenge's own edge. They are built like the
launcher's rows now: the lozenge is exactly the width of the list, and the
content is padded in from it by `rowPadX`. The back control at the top of a
device page shares that left edge rather than having its own, since it is
the same kind of thing — something under the pointer that a click will act
on — while its chevron stays at the page's content inset, lining up with the
clock and the tiles on the page behind it. It is shorter than the header row
it sits in (`backHeight`), so its lozenge has air above and below instead of
running into the rule underneath it and the panel's edge above.

**Quickshell builds every singleton at startup, so a `Process` left
`running: true` in one is a process at every launch and every config
reload.** That is right for the two whose answers decide *layout* —
`SysMon`'s hwmon probe sets `hasTemperature` and `Brightness`'s query sets
`available`, and both gate a `visible:` on a control-centre row, so a
deferred answer would pop a row into existence after the panel was already
on screen.

It was wrong for `Wallpaper`, which spawned `ls` and `readlink` at every
startup for a panel that is built on demand and may never be opened.
Nothing outside `WallpaperPanel` reads any of it, and the panel calls
`refresh()` as it becomes visible — so `refresh()` is now the only thing
that starts either process, and an untouched wallpaper picker costs nothing.

Everything else that could poll, doesn't. `SysMon`'s three timers are bound
to the control centre being visible, the visualiser's animations to
`Media.isPlaying && visible`, and `Brightness` never polls at all — it
re-reads when the panel opens, and writes behind a 60ms coalescing timer
with at most one process in flight, so a slider drag cannot spawn sixty
processes a second.

**The control centre's header is one block, not two columns that happen to
start at the same y.** The clock and the day strip run down the left, the
three meters down the right, and the meters are bottomed on the strip rather
than given a height of their own — so however tall either side gets, they
end on the same line. `StatBar` is fully elastic for exactly this: the
reading sits on top, the mark underneath, and the track takes whatever is
left, so a taller box just means a longer bar. That is also why there is no
`vitalsHeight` any more; a second number to keep in sync with the strip is a
number that eventually isn't.

The month is a label on that row, not a second headline. At 24px it was
competing with the time for the top-left corner and crowding a 10px weekday
row from six pixels away; at 17 the hierarchy reads time, then dates, then
the month naming them. `calMonthWidth` is measured rather than guessed — the
widest three-letter month, "May", at whatever size the label is set to — so
it moved from 50 to 36 with the font and has a note to re-measure if that
changes again.

**The radios are bindings, never one-shot reads.** `Wifi.qml` and `Bt.qml`
wrap `Quickshell.Networking` and `Quickshell.Bluetooth`, which populate a
second or two after the shell starts — read either of them once at
construction and you get an empty answer that never corrects itself. Both
also do the derivation the view shouldn't: picking the wifi device out of the
device list and then the network it is actually on, or reducing a device list
to "what is connected right now". `Bt` is called that rather than `Bluetooth`
so it can't collide with the Quickshell singleton it wraps.

Tiles carry state in the badge behind the mark, not in the tile background.
A whole tile changing colour reads as "selected", which is not what on/off
means. `available` is separate from `active` for the same reason: no adapter
at all is a different thing from an adapter that is switched off, and only
one of them is worth clicking.

The radio's own on/off, at the top of its page, is a switch rather than the
pill that used to say "On" or "Off" in words. The words were doing two jobs
at once — naming the state and being the control — where a switch says the
same thing by where the knob is, in a shape that is obviously something you
can flip. The knob slides rather than jumping, for the same reason the
segmented control's thumb does, and it is dimmed when it is off: everything
in this shell says "not doing anything" by receding, and a bright white knob
on a quiet track is a loud way to say off.

**Brightness goes through brightnessctl, not sysfs.** The backlight
attribute is root-owned and there is no Quickshell module for it, so writes
shell out — brightnessctl falls back to logind's `SetBrightness` when it
can't write sysfs directly, which is what makes this work without the user
being in the `video` group or a udev rule being installed. `-c backlight`
matters: without it brightnessctl also enumerates LED devices and spews read
errors for the ones it can't open.

Dragging the slider sets the value optimistically and writes behind a 60ms
coalescing timer with at most one process in flight, so a drag doesn't spawn
sixty processes a second. A reading that arrives while a drag is in progress
is discarded rather than fighting the drag. Nothing polls the backlight —
`ControlCenter` re-reads it when the panel becomes visible, which covers the
brightness keys changing it behind the shell's back.

**The keyboard-driven panels ask for the keyboard, and only while they are
up.** A layer-shell surface has to request keyboard focus explicitly, and
`WlrLayershell.keyboardFocus` follows `Notch.wantsKeyboard` — the launcher,
the wallpaper picker and the theme picker, `Exclusive` for those and `None`
otherwise. Asking for it the rest of the time would pull focus off whatever
you were typing into every time the notch widened for a track change. None
of the three can be opened by hovering the bar, so any of them being up is
already something you asked for.

That list has to be kept in step with the panels themselves: the theme
picker grew arrow keys, `Enter` and `Escape` the moment it became a strip,
and until it was added here those keys went nowhere. It is worth knowing
that `Exclusive` really is exclusive while they are open: `Escape` is the
way out, and `ipc call notch close` is the way out if something goes
wrong.

The search field keeps focus for the whole life of the panel. The arrow keys
move a selection index in the list rather than moving focus into it, so
typing never stops working, and mouse hover writes to the same index so the
highlight is never in two places at once. Ranking is deliberately crude — a
name that starts with what you typed beats one that merely contains it, which
beats a match on the generic name, keywords or desktop id — which is what
makes `term` land on your terminal and `pass` on your password manager.

Unlike the panels behind the bar, the launcher is **not** preloaded. It
builds a row per desktop entry on the machine and is never a hair-trigger
away from being shown, so it is built the first time it is asked for.

**Both kinds of bar are the same bar.** The vitals meters use SliderRow's
track: the same hairline width, the same track colour, the same white fill at
the same opacity — so a panel with five bars in it reads as one idea turned
on its side rather than two unrelated widgets. The one thing the meters keep
for themselves is going red past a threshold, because nothing a slider shows
can be alarming. The vitals block is sized by its *readings* rather than its
bars, since `8.4GB` is several times wider than the hairline it sits over.

**The control centre splits by read versus do.** Status reads across a
header; controls fill the body. Interleaving them was what made the panel
hard to scan — six things you touch mixed with seven you only read, in five
different visual grammars, so the eye re-learned the rules on every row.
There are two grammars left: a tile you tap and a row you read or drag.

The header holds the time cluster on the left — the clock over its own day
strip, which belong together — and the vitals on the right. Battery is one of
the vitals rather than a stray line of text at the bottom: it is the same
kind of fact as the other three, and it was the only thing in the panel with
no container at all.

The whole header sits *outside* the pager, because none of it changes with
the page and reading it shouldn't cost you your place in a device list. The
clock has a second reason to be there: it is the notch clock's landing
target, so it has to hold still.

Dropping the old full-height vitals column recovered a quarter of the
panel's width, which went to the tiles — device names like
`BLUEANT SOUNDBLADE` now fit instead of eliding.

**The control centre pages; the notch doesn't.** Tapping a radio tile slides
in a list of networks or paired devices rather than opening a second window
or resizing the notch again. All three pages are the same fixed size inside
one panel, so the state machine in `Notch.qml` still only knows about
`"control"` — paging is `ControlCenter`'s own business. The outgoing page
moves a fraction of the width while the incoming one comes the whole way,
which reads as depth rather than as two things swapping places.

The clock sits deliberately *outside* the pager. It is what the notch's own
clock flies into, so it has to hold still: a landing target that slid off to
the left mid-flight would drag the clock along with it. The page resets to
main whenever the panel hides, so reopening never lands on a list you left
open yesterday.

Wifi scanning runs only while its page is visible, bound to `visible` rather
than set in a handler so it switches off however the page is left — including
the notch simply closing. **Joining a new secured network isn't supported**:
that needs a password, and a notch has nowhere to ask for one. Known networks
reconnect from stored secrets and open ones need none, so those work; the
rest are listed and dimmed rather than pretended at.

In a device list, dimming is separate from tappability. The row you are
already on isn't tappable either, and dimming it would make the current
device the faintest thing in the list — so only rows you genuinely can't act
on recede.

**Battery and power profile share a card.** They are the same subject — how
much you have left, and how fast you would like to spend it — so they read as
one thing rather than two facts at opposite ends of the panel.

A bare row wasn't enough: a naked reading beside a filled pill still reads as
two objects. The card is the same shape, colour, radius and height as a
`ToggleTile`, so it lands as another row of the same grid, and the picker
recesses to the surface colour inside it — hairline on hairline would have
been invisible, which is why `SegmentedControl` takes its track colour as a
property.

That also got battery out of the vitals, where it never belonged. CPU,
temperature and memory move by the second and are worth a live meter; a
battery moves over hours, so a bar tells you nothing a number doesn't. The
vitals are three again, and the width that freed went to the day strip.

The state line is state-driven rather than a bare on-AC test. This machine
sits in `PendingCharge` — plugged in and holding at a charge limit — which
the old "charging unless on battery" reading called *Charging*, and it is
not. `timeToEmpty` and `timeToFull` are each used only in their own state:
UPower still reports a `timeToEmpty` while on AC, and it is nonsense (179
hours, at the time of writing).

**Power profiles are a segmented control, not a cycling tile.** With three
options, cycling makes you tap twice to go backwards and never shows you what
the other choices are; a segmented control shows all of them and puts any one
a single tap away. The thumb slides rather than jumping, so it is obvious
which segment you came from.

The options are built from what the daemon actually offers rather than
assumed: a machine without the thermal headroom reports no performance
profile, and `Power.qml` leaves it out rather than offering a mode the daemon
will refuse. Quickshell's `PowerProfiles.profile` is writable, so switching is
an assignment — no shelling out to `powerprofilesctl`.

**The power menu acts on the first click.** Opening the panel is already the
deliberate part, and a menu that asks "are you sure" is a menu you press
twice every time. The three irreversible actions turn red under the pointer
instead — a moment of colour before you commit, which is the only warning
there is.

**Its four actions are a 2x2, not a row.** A row of four made the panel
wider than the control centre to hold four words, and put Lock — the only
one of the four that isn't destructive, and the one most often wanted — at
the end of a long horizontal reach. The square is about the size of the
thing it is, and no corner is far from any other. The order is the row's,
wrapped: the two that take the machine down on top, the two that act on the
session below, which lands Lock in the bottom right.

It is a `GridLayout` with the buttons on `fillWidth`/`fillHeight` rather
than two `Row`s, so the columns stay the same width without either row being
told about the other. `powerMenuWidth` is derived from `powerButtonWidth`
for the same reason — the button width is what the buttons settle at, not
something they are pinned to, and deriving the panel from it means the two
can't drift apart. The height stays a literal: the heading's height is
measured from its own font, which `Config` has no business knowing.

Its four commands live in `Config` rather than in the code, so a different
session, init or locker is a config change.

**Log out goes through `Quickshell.Hyprland`, not `hyprctl`.**
`Hyprland.dispatch()` writes straight to Hyprland's request socket, so there
is no process to spawn — and, unlike a `Process` whose output nobody reads,
a refused dispatcher comes back as a warning in the log instead of vanishing.
That silence is what made the original bug invisible: the button fired,
hyprctl errored, and nothing said so.

The dispatcher itself has two spellings, because Hyprland has two config
languages. Under the Lua config layer `hyprctl dispatch` evaluates its
argument as a Lua expression, so the plain `exit` parses as a bare
identifier and is rejected with *"expected a dispatcher"*; it has to be
`hl.dsp.exit()`, which is what the Ctrl+Q keybind in `hyprland.lua` was
already using. `Power.logoutRequest` picks between the two off
`Hyprland.usingLua` rather than assuming either, so this config logs out on
both.

It is a binding, not a read taken when the button is clicked, and that
matters: `usingLua` is false until the module has asked Hyprland what it is
running, and the answer lands a moment after the singleton is built. Read it
once, too early, and every session gets the wrong syntax — which is exactly
what a first attempt at testing this did, reporting `usingLua=false` on a
machine that was demonstrably running Lua.

Lock runs `hyprlock` directly.
Signalling logind with `loginctl lock-session` is the tidier call — it lets
whatever is registered to handle the lock do it, without this config naming
a locker — but nothing is registered unless something like hypridle is
running to listen for it, and on a machine without that the button did
nothing at all and said nothing about why. It is guarded the way hypridle's
own `lock_cmd` is (`pidof hyprlock || hyprlock`), so pressing it again while
the screen is locked can't stack a second locker on the first.

**Lock is the one action that is deliberately not a child of this shell.**
Quickshell kills a `Process` it owns when the object is destroyed, and that
happens on every config reload — so a locker started the way the other three
are would be killed by someone saving a QML file, which is to say the screen
would unlock itself. It goes through `Quickshell.execDetached` instead. Lock
is also the only one of the four that closes the notch on its way, because
it is the only one you come back from: the others end the session, so what
the notch does afterwards is nobody's business.

**Three panels wear the same heading, from one component.** The notification
centre, the power menu and the wallpaper picker all open on a title over a
hairline, and `PanelHeading.qml` is that title, that hairline, and the room
between them. They had been three copies, and three copies of a heading are
three headings that drift apart: only the notification centre ruled its
heading off, and each panel left a different gap under the title — 14, 16
and 14 — which is the kind of difference you can't see and can't unsee.

Anything a panel puts at the right of that line — `Clear`, the bell the bar
flies in — is declared inside the heading and anchored against
`parent.line`, the title's own line, rather than against the heading, which
is taller by a rule. Both panels grew by the difference: `powerMenuHeight`
and `wallpaperHeight` carry the extra hairline and gap rather than closing
up the air at the bottom.

**The wallpaper is a symlink, and the panel only moves it.** `Wallpaper`
lists `Config.wallpaperDir`, and choosing one repoints
`Config.wallpaperLink` at it with `ln -sfn`. Nothing is copied, nothing is
written into the wallpaper directory, and no state about which wallpaper you
picked is kept anywhere in this shell — the link *is* the setting, which is
why it survives the shell being restarted, replaced, or never started. It is
the same link `install.sh` writes, so the installer and the panel agree
about where the wallpaper lives without either knowing the other exists.

Repointing it isn't enough on its own, because hyprpaper reads the link once
at startup, so `Config.wallpaperApplyCommand` restarts it — detached rather
than as a child process, since a wallpaper daemon that dies with the shell
that asked for it is not a wallpaper daemon.

**The wallpaper in use is matched by filename, not by path.** `readlink -f`
resolves every symlink on the way to the file, and with the pictures stowed
out of a dotfiles repo, a wallpaper's canonical path looks nothing like the
path the strip listed it under — comparing the two found no match, and the
panel opened on the first picture insisting nothing was current. The strip
only ever shows one directory, so the filename is identity enough.

**The strip is a window that slides, not a list that scrolls.** One tile is
held on the centre line by `StrictlyEnforceRange` and the tiles move under
it, whichever way you moved them — a key, a flick, or a click on a
neighbour. Snapping falls out of that same rule rather than being arranged
separately, so there is no half-tile resting position to design around.
Clicking a tile off to the side brings it to the middle rather than setting
it, because the thing is worth looking at before you commit to it; the tile
in the middle is the one a click, `Enter` or `Set` applies. The tile you are
looking at is at full strength and its neighbours are knocked back, while
the one actually in use wears an accent ring — usually the same tile, and
the panel is no use on the occasions they aren't.

**The wallpaper picker and the theme picker are one shape.** Picking a
palette and picking a picture are the same job — look at a handful, take
one — so they are one set of numbers rather than two that drift: the
`strip*` block in `Config` holds the tile size, the gap, the dim, the edge
fade, the slide, and the panel width and height that both derive from. The
theme previews take the 16:9 frame the wallpapers need so the two panels are
recognisably the same object.

There is exactly one number the theme strip does not borrow, and it is worth
saying why. A dimmed photograph is still a photograph, but a palette dimmed
to `stripTileDim` is a grey blob — and the colours are the *entire content*
of the tile, so knocking the neighbours back that far hides the thing you
are being asked to choose between. `themeTileDim` is gentler: enough to say
"not this one", not so much that you can't see what "this one" would be.

Where a wallpaper tile shows the picture, a theme tile shows the shell — a
notch with a clock and an urgency dot hanging off the top edge, a pair of
tiles with a lit and an unlit badge, and a half-filled slider. Six colours
in the arrangement they will actually appear in, which says more than six
squares of colour would. It is the one place in the shell that paints in a
palette other than the one that is on.

Pictures are decoded at twice the tile width rather than at their own size:
ten 4K wallpapers is most of a gigabyte of pixels for a strip 135 tall.

**`bodyMarkupSupported` is off, and that is deliberate.** The rows render
`Text.PlainText`. Advertising markup we don't render is not a harmless
overstatement: a sender that believes the body is markup escapes it before
sending, so an ampersand in a message arrives as `&amp;` and gets drawn that
way. Chrome does exactly this. Turning the capability off is what makes a
Teams message about "R&D" say R&D.

**The notification centre is a live surface, and that is what makes it
awkward.** `Notifs` marks every notification `tracked` and keeps the sender's
D-Bus object on the entry, because an action can only be invoked on the
object that carried it. So dismissing a row tells the sender, clearing the
panel tells all of them, and rows whose sender offered actions draw them.

Every entry also carries a plain copy of what it said when it arrived. The
object only lives as long as the sender keeps the notification open; the
moment it closes, `Notifs.deactivate` swaps the entry for one with no handle,
and the row falls back to the copy. That is why a notification closed
elsewhere stays in the panel as a record with no buttons, rather than a row
of buttons over a pointer to nothing. `Notifs.view` is the rule in one line:
draw the live object where there is one, the copy where there isn't.

Order matters in that file, and the comments say so. History is assigned
before any notification is closed, because closing lands straight back in
`deactivate`, which looks through the history it is given.

The corollary of tracking is that a notification now stays open, as far as
its sender is concerned, until you dismiss it, clear the panel, or it falls
off the end of `historyLimit` — the panel keeps twenty, and closes whatever
it drops rather than leaving a sender holding a notification nobody can see.

**Actions close the notification, mostly.** Quickshell closes a notification
when one of its actions is invoked unless the sender set the `resident` hint
— the difference between "Reply" and a music player's "Next" — so `invoke`
reads that hint before invoking, and drops the row only if the sender was not
resident. The spec's `default` action isn't a button either: it is what
clicking the notification itself does, so it is filtered out of the button
row and put on the row as a whole. The buttons take the press outright
(`ReleaseWithinBounds`), which cancels the row's tap behind them — otherwise
hitting "Snooze" would also fire whatever the sender meant by a click.

**Senders may replace a notification in place** — a download's percentage, a
chat's message count. Quickshell updates the existing object rather than
emitting another, so rows bound to it rewrite themselves instead of stacking
a second copy underneath. The peek can't see that on its own, so `Notifs`
listens for the text changing and asks for another peek, through
`Qt.callLater` so that one replacement is one peek rather than one per
property it moved.

**Action buttons don't hide on hover**, unlike the dismiss cross. They carry
the sender's own words, so they read as part of the notification rather than
as chrome — and a button you have to go looking for is not a button. The row
grows by exactly the height the buttons came out at, so notifications without
any stay the size they were.

Rows are keyed by our own counter rather than the D-Bus id, because the spec
lets a sender reuse an id: dismissing by id would take every notification
that app had ever sent. Ages are relative and `Notifs.formatAge` takes `now`
as an argument rather than reading the clock, so the caller binds it to
`Time.now` and every row re-reads itself once a minute; a function that read
the clock itself would compute once and then sit there being wrong.

The dismiss cross appears on hover and takes the age's place rather than
sitting beside it, so the row doesn't reflow under the pointer — and twenty
permanent crosses down the panel would be a list of crosses, not a list of
notifications.

**The player name is a control.** Tapping it in the media panel steps to the
next MPRIS player and pins it. Pinning matters: without it the automatic
choice would win the panel back the moment whatever you had ignored started
playing again. The pin is by bus name rather than Quickshell's `uniqueId`, so
it survives the player restarting — relaunching Spotify gets you Spotify
back, where a per-session id would silently fall through to whatever else
happens to be open.

It reads `Spotify 2/2` — which of how many — so you can see there is
somewhere to step to without hovering to find out. The position appears only
when there is more than one player: `Spotify 1/1` would be noise, and its
absence is itself the signal. The label is dim until hovered, like everything
else here that only reveals itself under the pointer.

When nothing is playing, the automatic choice prefers a paused player over a
stopped one. That matters more than it sounds: a browser tab with a dead
media element is a stopped player with no metadata, and it would otherwise
take the panel from a paused music player that has an actual track in it.

**Volume is a system control, not a track control.** It sits in the control
centre under brightness rather than in the media panel, because it belongs to
the machine rather than to whatever happens to be playing — and the two
sliders reading identically next to each other says that better than either
of them could alone. `Audio.qml` owns the `PwObjectTracker` for the current
sink, since a PipeWire node's audio interface isn't bound until something
tracks it, which makes that singleton the one place that knows the volume.
Both sliders take a scroll, which is how the volume bar behaved when it lived
in the media panel.

**Audio devices cycle rather than opening a list.** There is no room in a
notch for a popup, and the tile has to keep showing the current device
either way, so tapping moves to the next one and wraps. `Audio.qml` filters
streams out — those are applications, not devices — and prefers a node's
nickname over its description, because "BenQ RD280U" beats "Radeon High
Definition Audio Controller Pro" and bluetooth nodes arrive with no nickname
at all. Switching writes `preferredDefaultAudioSink`, which is the
configured default rather than the momentary one.

**Everything shared is a singleton.** Clock, MPRIS selection, notification
history and open state all live in `services/`, outside `Variants`. Plugging
in a second monitor adds one window, not a second clock and a second D-Bus
connection.

**Both panels are preloaded, not lazy.** They build asynchronously 1.5
seconds after startup — late enough that the first frame is already on
screen, early enough that they're warm before anyone hovers. Opening either
is then a visibility change. `Notch.qml`'s `onOpenedChanged` covers the case
where someone is faster than the timer.

**Almost nothing polls.** MPRIS, UPower, PipeWire, NetworkManager, BlueZ and
notifications are all event driven. Three things aren't, and each only runs
while something is looking at it: the MPRIS position tick (MPRIS deliberately
doesn't push position, and it ticks only while the media panel is visible
*and* something is playing), the collapse delay, and the vitals.

The vitals genuinely have to poll. The kernel exposes load, temperature and
memory as files with no change notification, and CPU load is a *delta*
between two samples rather than a value you can read at all. `SysMon.qml`
therefore samples — but only while the control centre is visible, and it
drops its CPU baseline when it stops, so the first reading after opening is
measured over one interval rather than over however long the panel was shut.

Each metric gets its own cadence, because they move at wildly different
rates: load is bursty and wants a second, a CPU's thermal mass means its
temperature cannot meaningfully change that fast (2.5s), and memory drifts
slowly enough that a per-second reading is just noise (5s). Three timers
reading one file each is also cheaper than one timer reading all three, and
each bar animates its fill over its own period — a bar sampled every five
seconds animating over one would stall for four of them.

Memory reads as an amount rather than a proportion — the bar already says
what fraction is gone, so the number says how much that actually is. Binary
units, because that is what everything else on the machine means by GB when
it talks about RAM, and one decimal below ten with none above, so the reading
stays about as wide as the bar it sits over.

Readings are taken whole or not at all. A partial read of `/proc/meminfo`
that has `MemTotal` but not yet `MemAvailable` computes `(total - 0) / total`
— a confident, wrong 100% — so memory is held rather than derived, and only
updated from a parse that produced both.

hwmon numbering is not stable across boots, so the CPU sensor is found by
name once at startup rather than hardcoded to a path. The temperature bar is
drawn over 30–95°C rather than from zero, because a CPU never sits near zero
and a bar from there would barely move; past 80°C it turns red.

## Extending it

**Real audio bars.** `Visualizer.qml` currently fakes it. Run `cava` with
raw output through a `Process` + `SplitParser` in a singleton and bind each
bar's `level` to a real band.

**Inline reply.** The one part of the notification spec the panel still
doesn't do. `NotificationServer` has an `inlineReplySupported` flag, and a
notification that offers it has `hasInlineReply` and
`inlineReplyPlaceholder`, with `sendInlineReply(text)` to answer. It needs a
text field in `NotificationRow` where the buttons are, and the same
live-object handling they already have.

**More panels.** The obvious next step is a second page in the expanded
state — a file shelf, workspace previews. Add it as another
fixed-size `Loader` inside `contentClip`, activate it on the same preload
timer, and add a case to `targetWidth`/`targetHeight`.

**A file shelf.** Quickshell doesn't expose Wayland drag-and-drop drops yet,
so a NotchNook-style shelf needs a different trigger — an IPC call from a
file manager script, or watching a directory with `FileView`.

## Known rough edges

- Unloading a `PanelWindow` crashes on some Smithay-based compositors
  (COSMIC). This config never unloads its window, so it isn't affected, but
  keep it in mind if you add popups that toggle `LazyLoader.active`.
- The notch appears on every monitor and all of them open together, since
  `NotchState.forced` is global. For primary-only, filter the `Variants`
  model in `shell.qml`.
