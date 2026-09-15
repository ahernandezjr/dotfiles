# System-level NixOS prerequisites for Skyrim SE/AE modding
# Handles kernel sysctl limits, open file descriptors for USVFS/DynDOLOD, and Steam compat mounts.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.systemSettings.gaming.skyrim;
  geProtonPkg = pkgs."ge-proton-10-34";
in
{
  options.systemSettings.gaming.skyrim = {
    enable = lib.mkEnableOption "Skyrim modding system-level tuning and kernel prerequisites";
  };

  config = lib.mkIf cfg.enable {
    # Raised vm.max_map_count to 2147483642 to prevent memory allocation crashes
    # in heavily modded Skyrim SE/AE installations and large DynDOLOD 3+ runs.
    boot.kernel.sysctl = {
      "vm.max_map_count" = lib.mkDefault 2147483642;
    };

    # High open-files limits (nofile = 524288) required by USVFS virtual file system (MO2)
    # and batch asset processing in DynDOLOD/TexGen.
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "soft";
        value = "524288";
      }
      {
        domain = "*";
        item = "nofile";
        type = "hard";
        value = "524288";
      }
    ];

    # Prerequisite system packages & utilities for Wine GE-10-34 & SteamTinkerLaunch compatibility
    environment.systemPackages = [
      geProtonPkg
      pkgs.steamtinkerlaunch
      pkgs.xdotool
      pkgs.xprop
      pkgs.xwininfo
      pkgs.yad
      pkgs.steam-run
      pkgs.protontricks
      pkgs.winetricks
      pkgs.cabextract
      pkgs.p7zip
      pkgs.unzip
      pkgs.zenity
      pkgs.wget
      pkgs.fuse
    ];

    # Expose SteamTinkerLaunch to Steam compatibility tools
    programs.steam.extraCompatPackages = with pkgs; [
      steamtinkerlaunch
    ];

    # Symlink 32-bit glibc dynamic loader to /lib/ld-linux.so.2 on host system.
    # Required for standalone 32-bit Proton Wine binaries (GE-Proton, Proton-CachyOS, UMU-Proton)
    # to run natively when launched by Amethyst Mod Manager (Pandora Wizard / tools).
    system.activationScripts.ldso32 = ''
      mkdir -p /lib
      ln -sf ${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2 /lib/ld-linux.so.2
    '';

    # Allow Proton/Wine to access external game libraries and modlist paths on /mnt/linuxgames
    environment.sessionVariables = {
      STEAM_COMPAT_MOUNTS = "/mnt/linuxgames";
    };
  };
}
