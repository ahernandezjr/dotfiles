{
  config,
  lib,
  pkgs,
  ...
}:

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

    services.envfs.enable = true;

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse
        icu
        openssl
        freetype
        gnutls
        libGL
        pkgsi686Linux.freetype
        pkgsi686Linux.gnutls
        pkgsi686Linux.libGL
      ];
    };

    environment.systemPackages = with pkgs; [
      gamescope-wsi # Required for HDR to work
      steam-run
      protontricks
      winetricks
      cabextract
      p7zip
      unzip
      zenity
      wget
      fuse
    ];

    environment.sessionVariables = {
      STEAM_COMPAT_MOUNTS = "/mnt/linuxgames";
    };
  };
}
