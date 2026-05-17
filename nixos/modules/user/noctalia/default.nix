# Noctalia-shell: Home Manager config using native options.
# Settings are declared as Nix attribute sets for a fully declarative approach.
{ config, inputs, lib, pkgs, osConfig, ... }:

let
  isPortable = osConfig.networking.hostName == "work" || osConfig.networking.hostName == "laptop";
  
  # Import base settings, colors, and plugins from Nix files
  baseSettings = import ./settings.nix;
  baseColors = import ./colors.nix;
  basePlugins = import ./plugins.nix;

  # Define the battery widget to be added for portable hosts
  batteryWidget = {
    id = "Battery";
  };

  # If portable, add the battery widget to the right side of the bar
  # We do this by modifying the attribute set directly in Nix
  finalSettings = if isPortable then 
    lib.recursiveUpdate baseSettings {
      bar.widgets.right = baseSettings.bar.widgets.right ++ [ batteryWidget ];
    }
  else baseSettings;

in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = {
    programs.noctalia-shell = {
      enable = true;
      settings = finalSettings;
      colors = baseColors;
      plugins = basePlugins;
    };

    # Manage user-templates.toml separately
    xdg.configFile."noctalia/user-templates.toml".source = ./../../../../config/noctalia/user-templates.toml;
  };
}
