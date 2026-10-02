---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "ghostty"
local fileManager = "nautilus"
local morphinTime = "morphin ipc call"
local editor      = "zeditor"
local browser     = "zen-browser"
local datagrip    = "/opt/DataGrip-2024.1.4/bin/datagrip"
local webapp      = "google-chrome-stable --new-window --force-dark-mode --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --app="
local clamShell   = "~/.config/hypr/scripts/lid-switch"
local recorder    = "~/.config/hypr/scripts/record"


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod  = "SUPER" -- Sets "Windows" key as main modifier
local ctrlMod  = mainMod .. " + CTRL"
local shiftMod = mainMod .. " + SHIFT"


-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(
	ctrlMod .. " + Q",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(ctrlMod .. " + D", hl.dsp.exec_cmd(clamShell))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock")) -- Lock screen

-- Shell
local morph = function(keys, cmd, opts)
    hl.bind(keys, hl.dsp.exec_cmd(morphinTime .. " " .. cmd), opts)
end

morph(ctrlMod .. " + C",      "island toggle controlcenter") -- Control Settings
morph(ctrlMod .. " + M",      "island toggle media") -- MPRIS player
morph(mainMod .. " + Space",  "launcher toggle") -- App launcher
morph(mainMod .. " + Escape", "power toggle") -- Power menu
morph("XF86PowerOff",         "power toggle") -- Power menu
morph(ctrlMod .. " + W",      "wallpaper toggle") -- Wallpaper switcher
morph(ctrlMod .. " + T",      "theme toggle") -- Theme switcher
morph(ctrlMod .. " + S",      "settings toggle") -- Settings panel

-- Applications
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd(webapp .. "https://claude.ai"))
hl.bind(mainMod .. " + Y",      hl.dsp.exec_cmd(webapp .. "https://youtube.com"))
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(datagrip))
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("spotify-launcher"))
hl.bind("Print",                hl.dsp.exec_cmd(recorder .. ' "screenshot region"')) -- Screenshot region → edit in satty
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd(recorder .. ' "screenshot"')) -- Screenshot fullscreen → edit in satty
hl.bind(mainMod .. " + Print",  hl.dsp.exec_cmd(recorder .. ' "record region"')) -- Record region
hl.bind(shiftMod .. " + Print", hl.dsp.exec_cmd(recorder .. ' "record"')) -- Record fullscreen

-- Resize the current column
hl.bind(shiftMod .. " + Equal", hl.dsp.layout("colresize +conf"))
hl.bind(shiftMod .. " + F",     hl.dsp.layout("fit active"))
hl.bind(shiftMod .. " + Minus", hl.dsp.layout("colresize -conf"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focused window with mainMod + shift + arrow keys
hl.bind(shiftMod .. " + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(shiftMod .. " + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(shiftMod .. " + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(shiftMod .. " + down",  hl.dsp.window.swap({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,  hl.dsp.focus({ workspace = i }))
    hl.bind(shiftMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",  hl.dsp.workspace.toggle_special("magic"))
hl.bind(shiftMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Hardware keys: Multimedia and brightness
local held = { locked = true, repeating = true }

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    held
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    held
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    held
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    held
)
hl.bind("XF86AudioNext",       hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPause",      hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPlay",       hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPrev",       hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })
morph("XF86MonBrightnessUp",   "brightness up",   held)
morph("XF86MonBrightnessDown", "brightness down", held)

-- Toggle animations/blur/etc hotkey
hl.bind(mainMod .. " + F1", function()
	local game_mode = (hl.get_config("animations.enabled") == false)

	if game_mode then
		hl.exec_cmd("hyprctl reload")
		return
	end

	hl.config({
		general = {
			gaps_in = 0,
			gaps_out = 0, -- Disable gaps
			border_size = 0,
		},

		animations = {
			enabled = false, -- Disable animations
		},

		-- Disable blur, shadow and window rounding
		decoration = {
			shadow = { enabled = false },
			blur = { enabled = false },
			rounding = 0,
		},
	})
end)

-- Cycle layout for current workspace
hl.bind(mainMod .. " + tab", function()
	local layouts = { "scrolling", "dwindle" }
	local workspace = hl.get_active_workspace()

	if hl.get_active_special_workspace() then
		workspace = hl.get_active_special_workspace()
	end

	local next_layout = "dwindle"

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	if workspace.special then
		hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
	else
		hl.workspace_rule({ workspace = "name:" .. tostring(workspace.name), layout = next_layout })
	end
end)
