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
-- Home
hl.monitor({
    output = "desc:BNQ BenQ RD280U M5R0011601Q",
    mode = "2160x1440@59.95",
    position = "auto-left",
    scale = "1"
})
-- Office
hl.monitor({
    output = "desc:Acer Technologies ED320QR S 214603B423W01",
    mode = "1920x1080@120.00",
    position = "auto-left",
    scale = "1"
})

-- Trigger when the switch is toggled.
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr/hyprlock.conf"), { locked = true })
-- Trigger when the switch is turning on.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({ output = \"desc:BOE 0x0BCA\", disabled = true })'"), { locked = true })
-- Trigger when the switch is turning off.
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({ output = \"\", mode = \"preferred\", position = \"auto\", scale = \"auto\" })'"), { locked = true })
