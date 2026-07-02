# Noctalia: Home Manager config for Noctalia v5.
{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.userSettings.noctalia;
  baseColors = import ./colors.nix;

  endWidgets = [ "volume" "brightness" "tray" "notifications" "sysmon" ]
    ++ lib.optional cfg.isPortable "battery"
    ++ [ "clock" ];
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
    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace src/shell/hot_corners/hot_corners.cpp \
            --replace-warn 'void HotCorners::onConfigReload() {' 'void HotCorners::onConfigReload() { if (m_config == nullptr) return;'
        '';
      });
      settings = {
        shell = {
          ui_scale = 1.1;
          font_family = "Roboto";
          time_format = "{:%I:%M %p}";
          telemetry_enabled = false;
          avatar_path = "/home/alex/.face";
          panel = {
            transparency_mode = "soft";
            launcher_placement = "floating";
            launcher_position = "bottom_center";
            clipboard_placement = "floating";
            clipboard_position = "bottom_left";
            control_center_placement = "attached";
            control_center_position = "top_left";
            wallpaper_placement = "attached";
            wallpaper_position = "bottom_left";
            session_placement = "floating";
            session_position = "center";
          };
        };
        theme = {
          mode = "dark";
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
          templates = {
            enable_builtin_templates = true;
            builtin_ids = [ "btop" "gtk3" "gtk4" "ghostty" "niri" "qt" ];
            enable_community_templates = true;
            community_ids = [ "neovim" "obsidian" "discord" "steam" ];
          };
        };
        location = {
          auto_locate = false;
          address = "Crown Point, IN";
        };
        weather = {
          enabled = true;
          unit = "fahrenheit";
        };
        wallpaper = {
          directory = "/home/alex/Pictures/Wallpapers";
          automation = {
            enabled = true;
            interval_seconds = 3600;
            order = "random";
          };
          transition_on_startup = true;
        };
        bar.main = {
          position = "left";
          thickness = 34;
          background_opacity = 0.83;
          radius = 12;
          radius_top_left = -80;
          radius_bottom_right = -80;
          radius_top_right = -10;
          radius_bottom_left = -10;
          margin_ends = 0;
          margin_edge = 0;
          widget_spacing = 6;
          capsule = true;
          start = [ "control-center" "active_window" "media" ];
          center = [ "workspaces" ];
          end = endWidgets;
        };
        widget = {
          clock = {
            format = "%I:%M %p\n%b %d";
            vertical_format = "%m\n%d\n—\n%H\n%M";
          };
        };
        launcher = { 
          categories = false;
          session_search = true; 
        };
        hooks = {
          started = [
            "noctalia msg session lock"
            "noctalia msg wallpaper-random"
          ];
        };
      };
      customPalettes = {
        colors = baseColors;
      };
    };
  };
}
