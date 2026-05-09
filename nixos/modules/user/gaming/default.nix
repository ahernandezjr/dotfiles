{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userSettings.gaming;
in
{
  options = {
    userSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming-related packages and config";
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
