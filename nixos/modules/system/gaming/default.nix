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

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.millennium-steam;
    };

    environment.systemPackages = with pkgs; [
      gamescope-wsi # Required for HDR to work
      steam-run
    ];

    environment.sessionVariables = {
      # Disable driver-side VRR globally to reduce flicker.
      __GL_VRR_ALLOWED = "0";
      # Prefer FIFO present mode to avoid tearing/flicker.
      MESA_VK_WSI_PRESENT_MODE = "fifo";
    };
  };
}
