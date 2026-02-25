# Outputs (run `niri msg outputs` for your display names)
{ lib, parseMode }: {
  outputs = {
    "DP-5" = {
      mode = parseMode "1920x1080@60";
      scale = 1;
      transform.rotation = 90;
      position = { x = 0; y = 0; };
    };
    "HDMI-A-3" = {
      mode = parseMode "3840x2160@143.999";
      scale = 1.25;
      position = { x = 1080; y = 192; };
      focus-at-startup = true;
    };
    "DP-3" = {
      mode = parseMode "2560x1440@143.998";
      scale = 1;
      position = { x = 4152; y = 480; };
    };
  };
}
