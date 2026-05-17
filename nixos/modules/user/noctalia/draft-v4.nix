# Noctalia V4 Draft Configuration (Unused)
# Reference: https://docs.noctalia.dev/v4/getting-started/nixos/
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge;
  
  # Example of profile-specific settings
  isPortable = config.networking.hostName == "work" || config.networking.hostName == "laptop";
  
  # Base settings that apply to all hosts
  baseSettings = {
    general = {
      theme = "material3";
      location = "top";
    };
    bar = {
      enabled = true;
      modules = [ "clock" "workspaces" "network" "audio" ];
    };
  };

  # Portable-specific overrides (adding battery module)
  portableSettings = {
    bar = {
      modules = baseSettings.bar.modules ++ [ "battery" ];
    };
  };

  # Final merged settings based on profile
  finalSettings = if isPortable then (mkMerge [ baseSettings portableSettings ]) else baseSettings;

in
{
  # This module is intentionally disabled/unused for now.
  # To enable, rename to default.nix and adjust imports.
  options.userSettings.noctalia-v4 = {
    enableDraft = lib.mkEnableOption "Noctalia V4 Draft Config";
  };

  config = mkIf config.userSettings.noctalia-v4.enableDraft {
    programs.noctalia-shell = {
      enable = true;
      # The 'settings' option in V4 accepts a Nix attribute set that is converted to JSON.
      settings = finalSettings;
      
      # Colors must define all keys if overridden.
      # colors = {
      #   mPrimary = "#c1c1ff";
      #   ...
      # };
    };

    # System services required by Noctalia for full functionality:
    # networking.networkmanager.enable = true;
    # hardware.bluetooth.enable = true;
    # services.upower.enable = true;
    # services.power-profiles-daemon.enable = true;
    # services.gnome.evolution-data-server.enable = true; # for calendar
  };
}
