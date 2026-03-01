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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        wine

        # Optimizers and Utils
        mangohud
        protonup-qt
        vulkan-tools

        # Platforms
        millennium-steam
        lutris
        heroic
        prismlauncher
      ];
    }
  ]);
}
