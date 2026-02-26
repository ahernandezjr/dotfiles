{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.gaming;
in
{
  options = {
    userSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming-related packages and config";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Optimizers and Utils
      gamescope
      gamemode
      mangohud
      protonup-qt

      # Platforms
      millennium-steam
      lutris
      heroic
      prismlauncher
    ];
  };
}
