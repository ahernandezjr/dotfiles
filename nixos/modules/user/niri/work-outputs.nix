# Work laptop outputs
{ lib, parseMode }: {
  outputs = {
    "eDP-1" = {
      mode = parseMode "2560x1600@165.000"; # Typical high-res laptop screen, adjust if needed
      scale = 1.25;
      position = { x = 0; y = 0; };
    };
    "DP-1" = {
      mode = parseMode "1920x1080@60.000";
      scale = 1.0;
      position = { x = 2048; y = 0; }; # 2560 / 1.25 = 2048
    };
    "DP-2" = {
      mode = parseMode "1920x1080@60.000";
      scale = 1.0;
      position = { x = 3968; y = 0; }; # 2048 + 1920
    };
  };
}
