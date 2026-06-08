{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userSettings.gaming;
in
{
  options = {
    userSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming-related packages and config";
      sunshine = {
        enable = lib.mkEnableOption "Sunshine user-level configuration (web app)";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        # Better wine package for 32/64 bit support
        wineWow64Packages.staging
        wine-wayland
        winetricks

        # Optimizers and Utils
        mangohud
        protonup-qt
        vulkan-tools

        deadlock-mod-manager
        # Platforms
        (lutris.override {
          extraPkgs = pkgs: [
            wineWow64Packages.staging
            winetricks
            vulkan-tools
          ];
          extraLibraries =  pkgs: [
            vulkan-loader
            gnutls
            openldap
            libgpg-error
            libpulseaudio
            sqlite
            libva
            libvdpau
            libGL
            stdenv.cc.cc.lib
            # Additional common dependencies
            libxcrypt-legacy
            nettools
            gettext
          ];
        })
        adwaita-icon-theme
        heroic
        prismlauncher
        # ScopeBuddy (gamescope helper)
        (inputs.just-one-more-repo.packages.${pkgs.stdenv.hostPlatform.system}.scopebuddy)
      ];

      xdg.desktopEntries.sunshine-ui = lib.mkIf cfg.sunshine.enable {
        name = "Sunshine Web UI";
        exec = "${pkgs.brave}/bin/brave --app=https://localhost:47990";
        icon = "sunshine";
        terminal = false;
        categories = [ "Settings" "Game" "X-Gaming" ];
      };

      xdg.desktopEntries."com.heroicgameslauncher.hgl" = {
        name = "Heroic Games Launcher";
        exec = "systemd-run --user --scope --description=\"Heroic Games Launcher\" ${pkgs.heroic}/bin/heroic %u";
        icon = "com.heroicgameslauncher.hgl";
        terminal = false;
        categories = [ "Game" ];
        mimeType = [ "x-scheme-handler/heroic" ];
      };

      xdg.desktopEntries.steam = {
        name = "Steam";
        exec = "systemd-run --user --scope --description=\"Steam\" steam %U";
        icon = "steam";
        terminal = false;
        categories = [ "Network" "FileTransfer" "Game" ];
        mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
      };

      home.file = {
        scb-config = {
          enable = true;
          text = ''
            SCB_AUTO_RES=1
            SCB_AUTO_HDR=0
            SCB_AUTO_VRR=0
            SCB_GAMESCOPE_ARGS="--mangoapp -f --force-grab-cursor"
          '';
          target = "${config.xdg.configHome}/scopebuddy/scb.conf";
        };
      };
    }
  ]);
}
