---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "ghostty"
local fileManager = "nautilus"
local launcher    = "rofi -show drun -theme ~/.config/rofi/launcher.rasi"
local runner      = "rofi -show run -theme ~/.config/rofi/launcher.rasi"
local editor      = "vscodium --ozone-platform=wayland"
local browser     = "zen-browser"
local webapp      = "google-chrome-stable --new-window --force-dark-mode --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --app="


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local shiftMod = mainMod .. " + SHIFT"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(shiftMod .. " + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/wlogout"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr/hyprlock.conf"))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i -display-columns 2 -p \"\" -theme ~/.config/rofi/cliphist.rasi | cliphist decode | wl-copy")) -- Clipboard
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("hyprctl hyprpaper wallpaper ', ~/.config/wallpaper, cover'")) -- Reload wallpaper

-- Applications
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(string.format("pkill -x rofi || %s", launcher)))
hl.bind(shiftMod .. " + space", hl.dsp.exec_cmd(string.format("pkill -x rofi || %s", runner)))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(webapp .. "https://claude.ai"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(webapp .. "https://youtube.com"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("datagrip"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify-launcher"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --raw | satty -f -")) -- Screenshot region → edit in satty
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -m DP-3 --raw | satty -f -")) -- Full screen → edit in satty

-- Resize the current column
hl.bind(shiftMod .. " + Equal", hl.dsp.layout("colresize +conf"))
hl.bind(shiftMod .. " + F", hl.dsp.layout("fit active"))
hl.bind(shiftMod .. " + Minus", hl.dsp.layout("colresize -conf"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focused window with mainMod + shift + arrow keys
hl.bind(shiftMod .. " + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(shiftMod .. " + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(shiftMod .. " + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(shiftMod .. " + down", hl.dsp.window.swap({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i}))
    hl.bind(shiftMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(shiftMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
