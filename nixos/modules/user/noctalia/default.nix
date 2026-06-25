# Noctalia-shell: Home Manager config using native options.
# Settings are declared as Nix attribute sets for a fully declarative approach.
{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.userSettings.noctalia;
  
  # Import base settings, colors, and plugins from Nix files
  baseSettings = import ./settings.nix;
  baseColors = import ./colors.nix;
  basePlugins = import ./plugins.nix;

  # Define the battery widget to be added for portable hosts
  batteryWidget = {
    id = "Battery";
  };

  # If portable, add the battery widget to the right side of the bar
  finalSettings = if cfg.isPortable then 
    lib.recursiveUpdate baseSettings {
      bar.widgets.right = baseSettings.bar.widgets.right ++ [ batteryWidget ];
    }
  else baseSettings;

  jsonFormat = pkgs.formats.json { };
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  options.userSettings.noctalia = {
    enable = lib.mkEnableOption "Noctalia shell configuration";
    isPortable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable battery widget for portable laptops/workstations";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      # Leave these empty so the home-manager module does not generate read-only config files
      settings = { };
      colors = { };
      plugins = { };
    };

    # Copy files on activation instead of symlinking them to the Nix store.
    # This keeps them writable so the wallpaper coloring and settings GUI work without read-only warnings.
    home.activation.noctaliaWritableConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      TARGET_DIR="$HOME/.config/noctalia"
      mkdir -p "$TARGET_DIR"

      copy_writable() {
        local src="$1"
        local dest="$TARGET_DIR/$2"
        if [ -L "$dest" ]; then
          rm "$dest"
        fi
        cp -f "$src" "$dest"
        chmod +w "$dest"
      }

      copy_writable "${jsonFormat.generate "noctalia-settings.json" finalSettings}" "settings.json"
      copy_writable "${jsonFormat.generate "noctalia-colors.json" baseColors}" "colors.json"
      copy_writable "${jsonFormat.generate "noctalia-plugins.json" basePlugins}" "plugins.json"
      copy_writable "${./../../../../config/noctalia/user-templates.toml}" "user-templates.toml"
    '';
  };
}
