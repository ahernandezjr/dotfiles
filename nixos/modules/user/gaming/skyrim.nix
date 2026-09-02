{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.gaming.skyrim;
  amethystPkg = pkgs."amethyst-mod-manager";
  jackifyPkg = pkgs.jackify;
  mo2Pkg = pkgs."mo2-fhs";
  runnerPkg = pkgs."skyrim-tools-runner";
  geProtonPkg = pkgs."ge-proton-10-34";
in
{
  options = {
    userSettings.gaming.skyrim = {
      enable = lib.mkEnableOption "Skyrim SE/AE modding suite (Amethyst, Jackify, MO2, GE-Proton10-34 runner, Bethesda tools)";
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
    ] ++ lib.optionals cfg.mo2.enable [
      mo2Pkg
    ];

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
          exec = "${jackifyPkg}/bin/jackify %u";
          icon = "com.jackify.app";
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
