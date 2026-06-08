# Troubleshooting Guide

This guide documents common issues, workarounds, and debugging steps for this NixOS configuration.

---

## 1. Sandbox/Bubblewrap Apps (Steam, Heroic, Flatpaks) failing to launch from compositor launchers (Niri, Noctalia)

### Symptoms
Applications wrapped in Bubblewrap (e.g., Steam, Heroic Games Launcher, Helium) or Flatpaks fail to start when launched via the compositor (Niri binds, Noctalia/Quickshell menus, etc.), but launch perfectly fine when run from an active terminal (kitty, alacritty, bash, zsh).

### Cause
Bubblewrap wraps these applications with the `--die-with-parent` flag, which internally uses the Linux system call `PR_SET_PDEATHSIG` to monitor the parent thread/process.
When a compositor like Niri or a launcher like Noctalia spawns a process, it frequently does so from a transient thread or helper process that terminates immediately after initiating the spawn. When that spawning thread dies:
1. Bubblewrap detects the parent thread has exited.
2. It sends `SIGKILL` or `SIGTERM` to the sandboxed application.
3. The application terminates instantly before showing any window.

In contrast, when run from an active terminal, the terminal shell process remains alive, so the parent process persists, and the application starts normally.

### Solution
Wrap the application launch command in a systemd transient user scope. Since `systemd --user` is a persistent daemon whose spawning threads do not terminate, Bubblewrap's parent-death tracking will not be triggered.

#### NixOS / Home Manager Workaround
Override the application's desktop entry `exec` command to wrap the executable in `systemd-run --user --scope`:

```nix
xdg.desktopEntries."com.example.app" = {
  name = "Example App";
  exec = "systemd-run --user --scope --description=\"Example App Description\" ${pkgs.example-app}/bin/example-app %u";
  icon = "com.example.app";
  terminal = false;
  categories = [ "Game" ];
  mimeType = [ "x-scheme-handler/example" ];
};
```

This ensures that the launcher delegates spawning to systemd, keeping the parent process alive and bypassing the compositor's signaling bug.
