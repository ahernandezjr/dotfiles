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
    # Raised max_map_count for heavily modded Skyrim SE/AE & DynDOLOD memory allocations
    boot.kernel.sysctl = {
      "vm.max_map_count" = lib.mkDefault 2147483642;
    };

    # High open-files limits for USVFS / MO2 / DynDOLOD file descriptors
    security.pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "soft"; value = "524288"; }
      { domain = "*"; item = "nofile"; type = "hard"; value = "524288"; }
    ];

    # Prerequisite system packages & libraries for Wine GE 10-34 sandbox
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

    environment.sessionVariables = {
      STEAM_COMPAT_MOUNTS = "/mnt/linuxgames";
    };
  };
}
