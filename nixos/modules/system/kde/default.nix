# KDE Plasma 6.
{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.kde;
in
{
  options.systemSettings.kde = {
    enable = lib.mkEnableOption "KDE Plasma 6";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
  };
}
