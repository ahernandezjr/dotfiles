# spawn-at-startup, prefer-no-csd, screenshot-path, environment, hotkey-overlay
{ config, lib, term }: {
  spawn-at-startup = [
    { argv = [ "noctalia-shell" ]; }
    { argv = [ "sh" "-lc" "sleep 1.5; noctalia-shell ipc call wallpaper random; noctalia-shell ipc call lockScreen lock" ]; }
  ];
  prefer-no-csd = true;
  screenshot-path = null;
  environment = {
    DISPLAY = ":0";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    TERMINAL = term;
  };
  hotkey-overlay.skip-at-startup = true;
}

