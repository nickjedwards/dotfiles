------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
-- Built-in display
hl.monitor({
    output   = "eDP-1",
    mode     = "2256x1504@60.00",
    position = "auto",
    scale    = 1.33,
})
-- Home
hl.monitor({
    output = "desc:BNQ BenQ RD280U M5R0011601Q",
    mode = "2160x1440@59.95",
    position = "auto-left",
    scale = 1,
})
-- Office
hl.monitor({
    output = "desc:Acer Technologies ED320QR S 214603B423W01",
    mode = "1920x1080@120.00",
    position = "auto-left",
    scale = 1,
})

-- Trigger when the switch is toggled.
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("dms ipc call lock lock"), { locked = true })
-- Trigger when the switch is turning on.
hl.bind("switch:on:Lid Switch", function()
    hl.monitor({ output = "eDP-1", disabled = true })
    hl.dsp.exec_cmd("brightnessctl -sd chromeos::kbd_backlight set 0") -- Disable keyboard backlight
end, { locked = true })
-- Trigger when the switch is turning off.
hl.bind("switch:off:Lid Switch", function()
    hl.monitor({ output = "eDP-1", disabled = false })
    hl.dsp.exec_cmd("brightnessctl -rd chromeos::kbd_backlight") -- Restore keyboard backlight
end, { locked = true })
