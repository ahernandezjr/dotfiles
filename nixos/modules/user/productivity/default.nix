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
      zoom.enable = lib.mkEnableOption "Zoom video conferencing";
      obsidian.enable = lib.mkEnableOption "Obsidian writing software";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.flatten [
      (lib.optional cfg.onedrive.enable pkgs.onedrive)
      (lib.optional cfg.teams.enable pkgs.teams-for-linux)
      (lib.optional cfg.zoom.enable pkgs.zoom-us)
      (lib.optional cfg.obsidian.enable pkgs.obsidian)
    ];
  };
}
