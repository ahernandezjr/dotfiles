{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.userSettings.utilities;
in
{
  options = {
    userSettings.utilities = {
      enable = lib.mkEnableOption "Utility programs";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      baobab
      switcheroo
      eyedropper
      handy
      mpv
      vlc
      (ffmpeg-full.override {
          withUnfree = true;
      })
    ];
  };
}
