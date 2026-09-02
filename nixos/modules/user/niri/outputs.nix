# Outputs (run `niri msg outputs` for your display names)
{ lib, parseMode }: {
  outputs = {
    "DP-1" = {
      mode = parseMode "3840x2160@144.000";
      scale = 1.25;
      position = { x = 2560; y = 192; };
      focus-at-startup = true;
      variable-refresh-rate = true;
    };
    "DP-3" = {
      mode = parseMode "2560x1440@143.998";
      scale = 1;
      position = { x = 0; y = 480; };
      variable-refresh-rate = true;
    };
    "HDMI-A-1" = {
      mode = parseMode "3840x2160@143.999";
      scale = 1.25;
      position = { x = 2560; y = 192; };
      focus-at-startup = true;
      variable-refresh-rate = true;
    };
  };
}

