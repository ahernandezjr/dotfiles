{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.gaming;
in
{
  options.systemSettings.gaming = {
    enable = lib.mkEnableOption "system-level gaming optimizations";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false; # Set to false to fix 'Operation not permitted' crash
    };
  };
}
