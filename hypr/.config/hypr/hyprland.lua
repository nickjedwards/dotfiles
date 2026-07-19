-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


require("modules.monitors")
require("modules.environment")
require("modules.vibe")
require("modules.inputs")
require("modules.keybindings")
require("modules.rules")


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function ()
    -- Cursor theme
    hl.exec_cmd("hyprctl setcursor Banana-Catppuccin-Mocha 48")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Banana-Catppuccin-Mocha'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 48")

    -- GTK and icon theme
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'")

    hl.exec_cmd("dms run") -- DankMaterialShell

    hl.exec_cmd("wl-paste --type text --watch cliphist store") -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
end)
