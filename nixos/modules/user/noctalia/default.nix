# Noctalia: Home Manager config for Noctalia v5.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.userSettings.noctalia;
  baseColors = import ./colors.nix;

  endWidgets = [
    "volume"
    "brightness"
    "tray"
    "notifications"
    "sysmon"
  ]
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
      # Apply build-time patches to Noctalia source files
      package =
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
          (oldAttrs: {
            postPatch = (oldAttrs.postPatch or "") + ''
                      # Patch 1: Prevent crash if HotCorners reload is called before config is loaded
                      substituteInPlace src/shell/hot_corners/hot_corners.cpp \
                        --replace-warn 'void HotCorners::onConfigReload() {' 'void HotCorners::onConfigReload() { if (m_config == nullptr) return;'

                      # Patch 2: Treat standard numbers and keypad numbers interchangeably for shortcut matching
                      substituteInPlace src/core/input/key_chord.cpp \
                        --replace-warn 'bool keyChordMatches(const KeyChord& chord, std::uint32_t sym, std::uint32_t modifiers) noexcept {' \
                                       'bool keyChordMatches(const KeyChord& chord, std::uint32_t sym, std::uint32_t modifiers) noexcept {
              // Map standard numbers and KP number keys to each other for shortcuts
              std::uint32_t targetSym = chord.sym;
              if (targetSym >= XKB_KEY_1 && targetSym <= XKB_KEY_9 && sym >= XKB_KEY_KP_1 && sym <= XKB_KEY_KP_9) {
                if ((targetSym - XKB_KEY_1) == (sym - XKB_KEY_KP_1)) {
                  targetSym = sym;
                }
              } else if (targetSym >= XKB_KEY_KP_1 && targetSym <= XKB_KEY_KP_9 && sym >= XKB_KEY_1 && sym <= XKB_KEY_9) {
                if ((targetSym - XKB_KEY_KP_1) == (sym - XKB_KEY_1)) {
                  targetSym = sym;
                }
              }
              return targetSym == sym && chord.modifiers == modifiers;'
            '';
          });
      settings = {
        accessibility = {
          ui_scale = 1.1;
        };
        shell = {
          font_family = "Roboto";
          time_format = "{:%I:%M %p}";
          telemetry_enabled = false;
          avatar_path = "/home/alex/.face";
          launcher = {
            categories = false;
          };
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
          };
        };
        theme = {
          mode = "dark";
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
          templates = {
            enable_builtin_templates = true;
            builtin_ids = [
              "btop"
              "gtk3"
              "gtk4"
              "ghostty"
              "niri"
              "qt"
            ];
            enable_community_templates = true;
            community_ids = [
              "neovim"
              "obsidian"
              "discord"
              "steam"
            ];
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
          concave_edge_corners = true;
          radius_top_left = 0;
          radius_bottom_left = 0;
          radius_top_right = 12;
          radius_bottom_right = 12;
          margin_ends = 0;
          margin_edge = 0;
          widget_spacing = 6;
          capsule = true;
          start = [
            "control-center"
            "active_window"
            "media"
          ];
          center = [ "workspaces" ];
          end = endWidgets;
        };
        widget = {
          clock = {
            format = "%I:%M %p\n%b %d";
            vertical_format = "%H\n%M\n—\n%m\n%d";
          };
        }
        // lib.optionalAttrs cfg.isPortable {
          battery = {
            type = "battery";
            show_label = false;
          };
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
