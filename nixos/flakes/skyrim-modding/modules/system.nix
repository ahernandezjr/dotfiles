# System-level NixOS prerequisites for Skyrim SE/AE modding
# Handles kernel sysctl limits, open file descriptors for USVFS/DynDOLOD, and Steam compat mounts.
{ config, lib, pkgs, ... }:

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
      { domain = "*"; item = "nofile"; type = "soft"; value = "524288"; }
      { domain = "*"; item = "nofile"; type = "hard"; value = "524288"; }
    ];

    # Prerequisite system packages & utilities for Wine GE-10-34 compatibility
    environment.systemPackages = [
      geProtonPkg
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

    # Allow Proton/Wine to access external game libraries and modlist paths on /mnt/linuxgames
    environment.sessionVariables = {
      STEAM_COMPAT_MOUNTS = "/mnt/linuxgames";
    };
  };
}
