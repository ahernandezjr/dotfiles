# spawn-at-startup, prefer-no-csd, screenshot-path, environment, hotkey-overlay
{ config, lib, term }: {
  spawn-at-startup = [ { argv = [ "noctalia-shell" ]; } ];
  prefer-no-csd = true;
  screenshot-path = null;
  environment = {
    DISPLAY = ":1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    TERMINAL = term;
  };
  hotkey-overlay.skip-at-startup = true;
}
