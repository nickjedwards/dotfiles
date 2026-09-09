//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import qs.services

ShellRoot {
    id: root

    // One notch per monitor. All shared state lives in singletons under
    // services/, so adding a monitor costs one window, not one of everything.
    Variants {
        model: Quickshell.screens

        Notch {}
    }

    // Control the notch from keybinds without spawning a second Quickshell:
    //   qs -c ndvr ipc call notch toggle
    //   qs -c ndvr ipc call notch control
    //   qs -c ndvr ipc call notch launcher
    //   qs -c ndvr ipc call notch wallpaper
    //   qs -c ndvr ipc call notch theme
    //   qs -c ndvr ipc call notch close
    //
    // toggle/open act on the media panel, which is the one a "show me the
    // notch" keybind almost always means. The control centre has its own pair.
    IpcHandler {
        target: "notch"

        function toggle(): void {
            NotchState.toggle("media");
        }

        function open(): void {
            NotchState.open("media");
        }

        function control(): void {
            NotchState.toggle("control");
        }

        function openControl(): void {
            NotchState.open("control");
        }

        // The launcher is keyboard-driven and has no half of the bar to
        // hover, so IPC is the only way in.
        function launcher(): void {
            NotchState.toggle("launcher");
        }

        function openLauncher(): void {
            NotchState.open("launcher");
        }

        function notifications(): void {
            NotchState.toggle("notifications");
        }

        function openNotifications(): void {
            NotchState.open("notifications");
        }

        function power(): void {
            NotchState.toggle("power");
        }

        function openPower(): void {
            NotchState.open("power");
        }

        function wallpaper(): void {
            NotchState.toggle("wallpaper");
        }

        function openWallpaper(): void {
            NotchState.open("wallpaper");
        }

        function theme(): void {
            NotchState.toggle("theme");
        }

        function openTheme(): void {
            NotchState.open("theme");
        }

        function close(): void {
            NotchState.close();
        }

        // "closed", or one of NotchState.targets.
        function status(): string {
            return NotchState.forced === "" ? "closed" : NotchState.forced;
        }
    }

    // Cheaper still on Hyprland — no process spawn at all. Bind it in
    // hyprland.conf with:  bind = SUPER, N, global, quickshell:notchToggle
    //
    // import Quickshell.Hyprland
    // GlobalShortcut {
    //     appid: "quickshell"
    //     name: "notchToggle"
    //     onPressed: NotchState.toggle()
    // }
}
