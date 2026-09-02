# Home Manager User-level module for Skyrim SE/AE modding suite
# Installs mod managers, tool runners, XDG desktop shortcuts, nxm:// URL protocol handlers,
# and configures shared download/modlist directories between Amethyst, Jackify, Wabbajack Curator, and MO2.
{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.gaming.skyrim;
  amethystPkg = pkgs."amethyst-mod-manager";
  jackifyPkg = pkgs.jackify;
  wabbajackCuratorPkg = pkgs."wabbajack-curator";
  mo2Pkg = pkgs."mo2-fhs";
  runnerPkg = pkgs."skyrim-tools-runner";
  geProtonPkg = pkgs."ge-proton-10-34";
in
{
  options = {
    userSettings.gaming.skyrim = {
      enable = lib.mkEnableOption "Skyrim SE/AE modding suite (Amethyst, Jackify, Wabbajack Curator, MO2, GE-Proton10-34 runner, Bethesda tools)";

      downloadDir = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/linuxgames/modlists/mods";
        description = "Shared directory for downloaded mod archives (.zip, .7z, .rar) across Amethyst, Jackify, and MO2";
      };

      modlistsDir = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/linuxgames/modlists";
        description = "Root directory for installed modlists and Mod Organizer 2 instances";
      };

      amethyst = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Amethyst Mod Manager (Linux-native Qt6/Rust mod manager)";
        };
      };
      jackify = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Jackify (Linux-native Wabbajack installer)";
        };
      };
      wabbajackCurator = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Wabbajack Modlist Curator & Mod Comparison Suite";
        };
      };
      mo2 = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Mod Organizer 2 FHS runner under GE-Proton10-34";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install requested modding packages into user PATH
    home.packages = [
      geProtonPkg
      runnerPkg
      pkgs.protontricks
      pkgs.winetricks
      pkgs.vulkan-tools
      pkgs.zenity
    ] ++ lib.optionals cfg.amethyst.enable [
      amethystPkg
    ] ++ lib.optionals cfg.jackify.enable [
      jackifyPkg
    ] ++ lib.optionals cfg.wabbajackCurator.enable [
      wabbajackCuratorPkg
    ] ++ lib.optionals cfg.mo2.enable [
      mo2Pkg
    ];

    # Environment variables for shared paths
    home.sessionVariables = {
      SKYRIM_MOD_DOWNLOAD_DIR = cfg.downloadDir;
      SKYRIM_MODLISTS_DIR = cfg.modlistsDir;
      MO2_EXE_PATH = "${cfg.modlistsDir}/skyrim/ModOrganizer.exe";
    };

    # Automatically create shared directories
    home.activation.createSkyrimModdingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${cfg.downloadDir}"
      $DRY_RUN_CMD mkdir -p "${cfg.modlistsDir}"
    '';

    # Configure Amethyst Mod Manager defaults to use shared download directory
    xdg.configFile."AmethystModManager/amethyst.ini".text = lib.mkDefault ''
      [meta]
      version = 2

      [paths]
      downloads = ${cfg.downloadDir}
      modlists = ${cfg.modlistsDir}

      [ui]
      appearance_mode = dark
    '';

    # Desktop Applications & Nexus nxm:// scheme handling using official application icon assets
    xdg.desktopEntries = lib.mkMerge [
      (lib.mkIf cfg.amethyst.enable {
        amethyst-mod-manager = {
          name = "Amethyst Mod Manager";
          exec = "${amethystPkg}/bin/amethyst-mod-manager %u";
          icon = "amethyst-mod-manager";
          terminal = false;
          categories = [ "Game" "Utility" ];
          mimeType = [ "x-scheme-handler/nxm" ];
        };
      })

      (lib.mkIf cfg.jackify.enable {
        jackify = {
          name = "Jackify (Wabbajack)";
          exec = "${jackifyPkg}/bin/jackify";
          icon = "com.jackify.app";
          terminal = false;
          categories = [ "Game" "Utility" ];
        };
      })

      (lib.mkIf cfg.wabbajackCurator.enable {
        wabbajack-curator = {
          name = "Wabbajack Modlist Curator";
          exec = "${wabbajackCuratorPkg}/bin/wabbajack-curator";
          icon = "wabbajack-curator";
          terminal = false;
          categories = [ "Game" "Utility" ];
        };
      })

      (lib.mkIf cfg.mo2.enable {
        mo2-fhs = {
          name = "Mod Organizer 2 (GE-Proton10-34)";
          exec = "${mo2Pkg}/bin/mo2-fhs %u";
          icon = "modorganizer2";
          terminal = false;
          categories = [ "Game" "Utility" ];
          mimeType = [ "x-scheme-handler/nxm" ];
        };

        skyrim-tools-runner = {
          name = "Skyrim Tools Wine Runner";
          exec = "${runnerPkg}/bin/skyrim-tools-runner";
          icon = "wine";
          terminal = true;
          categories = [ "Game" "Utility" ];
        };
      })
    ];
  };
}
