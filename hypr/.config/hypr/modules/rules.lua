--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

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

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.workspace_rule({ workspace = "1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "5", persistent = true })

------------------
---- WINDOWS ----
------------------

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

-- Ghostty supports its own transparency
hl.window_rule({
  match   = { class = "com.mitchellh.ghostty"},
  opacity = "1.0 override 0.90 override",
})

hl.window_rule({
  match  = { class = "^firefox|zen$", title = "^Picture-in-Picture|Library$" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "vlc" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "qt5|6ct" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "org.pulseaudio.pavucontrol" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "blueman-manager" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "^nm-.*" },
  float  = true,
  center = true,
})

hl.window_rule({
  match  = { class = "org.gnome.Calculator" },
  float  = true,
  center = true,
})

hl.window_rule({
  match       = { class = "^xdg-desktop-portal-.*" },
  float       = true,
  center      = true,
  border_size = 0
})

hl.window_rule({
  match = { class = "xwaylandvideobridge" },
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
  match        = { namespace = "gtk-layer-shell" },
  blur         = true,
  ignore_alpha = 0,
})

hl.layer_rule({
  name         = "launcher",
  match        = { namespace = "rofi" },
  blur         = true,
  ignore_alpha = 0,
  dim_around   = true,
  xray         = false,
  animation    = "popin 25%"
})

hl.layer_rule({
  name         = "bar",
  match        = { namespace = "^wayle-bar-.*" },
  blur         = true,
  blur_popups  = true,
  ignore_alpha = 0.3,
  xray         = true,
})

hl.layer_rule({
  match = { namespace = "logout_dialog" },
  blur  = true,
})

hl.layer_rule({
  match = { namespace = "swayosd" },
  blur  = true,
})
