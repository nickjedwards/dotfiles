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
  -- Ghostty supports its own transparency
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
  match  = { class = "^org.quickshell" },
  float  = true,
  center = true,
})

hl.window_rule({
  match       = { class = "^xdg-desktop-portal-.*" },
  float       = true,
  center      = true,
  border_size = 0,
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
  match        = { namespace = "dms:dash" },
  blur         = true,
  ignore_alpha = 0,
  animation    = "slide up",
})

hl.layer_rule({
  match        = { namespace = "dms:control-center" },
  blur         = true,
  ignore_alpha = 0,
  animation    = "slide right",
})

hl.layer_rule({
  match = { namespace = "dms:(clipboard|notification-center-modal|power-menu|spotlight)" },
  blur         = true,
  ignore_alpha = 0,
  dim_around   = true,
  animation    = "slide bottom",
})

hl.layer_rule({
  match        = { namespace = "dms:(bar|tooltip|notification-center-popout|notification-popup|dash|system-update|polkit|process-list-popout|battery|popout)" },
  blur         = true,
  ignore_alpha = .25,
})
