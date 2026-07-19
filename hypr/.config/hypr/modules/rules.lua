--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.workspace_rule({ workspace = "1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "5", persistent = true })

------------------
---- WINDOWS ----
------------------

-- Opacity for inactive windows
hl.window_rule({ match = { float = false, focus = false }, opacity = "0.9 0.9" })

-- GNOME apps
hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, border_size = 0, rounding = 12 })

-- Floating windows
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(firefox|zen)$", title = "^Picture-in-Picture|Library$" }, float = true })
hl.window_rule({ match = { class = "vlc" }, float = true })
hl.window_rule({ match = { class = "qt5|6ct" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "^nm-.*" }, float = true })

-- Workspaces
hl.window_rule({
    name      = "code",
    match     = { class = "^(code|codium|dev.zed.Zed)$" },
    workspace = 2
})

hl.window_rule({
    name      = "browse",
    match     = { class = "zen" },
    workspace = 3
})

hl.window_rule({
    name      = "media",
    match     = { class = "Spotify" },
    workspace = 4
})

hl.window_rule({
    name      = "chat",
    match     = { class = "chrome-teams.microsoft.com__v2_-Default" },
    workspace = 5
})

hl.window_rule({
    match       = { class = "com.mitchellh.ghostty"},
    border_size = 0,
})

hl.window_rule({
    match       = { class = "^(google-chrome|firefox|zen)$" },
    border_size = 0,
})

-- Open DMS windows as floating by default
hl.window_rule({ match = { class = "^(com\\.danklinux\\.dms)$" }, float = true })

hl.window_rule({
    match       = { class = "^xdg-desktop-portal-.*" },
    float       = true,
    center      = true,
    border_size = 0,
})

hl.window_rule({
    match            = { class = "xwaylandvideobridge" },
    opacity          = "0.0 override 0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = {1, 1},
    no_blur          = true,
})

----------------
---- LAYERS ----
----------------

hl.layer_rule({
    match        = { namespace = "^(dms:.*)$" },
    blur         = true,
    ignore_alpha = 0,
})
