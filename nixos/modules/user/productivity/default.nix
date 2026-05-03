{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.productivity;
in
{
  options = {
    userSettings.productivity = {
      enable = lib.mkEnableOption "Productivity programs (onedrive, Microsoft integration, etc.)";
      onedrive.enable = lib.mkEnableOption "OneDrive synchronization package";
      teams.enable = lib.mkEnableOption "Microsoft Teams";
      edge.enable = lib.mkEnableOption "Microsoft Edge";
      zoom.enable = lib.mkEnableOption "Zoom video conferencing";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.flatten [
      (lib.optional cfg.onedrive.enable pkgs.onedrive)
      (lib.optional cfg.teams.enable pkgs.teams-for-linux)
      (lib.optional cfg.edge.enable pkgs.microsoft-edge)
      (lib.optional cfg.zoom.enable pkgs.zoom-us)
    ];
  };
}
