# Outputs (run `niri msg outputs` for your display names)
{ lib, parseMode }: {
  outputs = {
    "Guangxi Century Innovation Display Electronics Co., Ltd 32M2V 0000000000000" = {
      mode = parseMode "3840x2160@144.000";
      scale = 1.25;
      position = {
        x = 2560;
        y = 192;
      };
      focus-at-startup = true;
      variable-refresh-rate = false;
    };
    "Dell Inc. Dell S2417DG #ASMYHG2M2s7d" = {
      mode = parseMode "2560x1440@143.998";
      scale = 1;
      position = {
        x = 0;
        y = 480;
      };
      variable-refresh-rate = true;
    };
  };
}

