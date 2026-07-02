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
      # Apply build-time patches to Noctalia source files
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
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
  sym = targetSym;'
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
          session = {
            actions = [
              { action = "lock"; shortcut = "1"; }
              { action = "logout"; shortcut = "2"; }
              { action = "lock_and_suspend"; shortcut = "3"; }
              {
                action = "command";
                label = "Hibernate";
                glyph = "hibernate";
                command = "systemctl hibernate";
                shortcut = "4";
              }
              { action = "reboot"; shortcut = "5"; }
              { action = "shutdown"; shortcut = "6"; variant = "destructive"; }
            ];
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
        lockscreen_widgets = {
          enabled = true;
          schema_version = 2;
          widget_order = [
            "lockscreen-login-box@DP-5"
            "lockscreen-login-box@HDMI-A-3"
            "lockscreen-login-box@DP-3"
            "lockscreen-widget-0000000000000002"
            "lockscreen-widget-0000000000000003"
            "lockscreen-widget-0000000000000004"
          ];
          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };
          widget = {
            "lockscreen-login-box@DP-3" = {
              box_height = 70.0;
              box_width = 400.0;
              cx = 1280.0;
              cy = 1321.0;
              output = "DP-3";
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                input_opacity = 1.0;
                input_radius = 6.0;
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_password_hint = true;
              };
            };
            "lockscreen-login-box@DP-5" = {
              box_height = 70.0;
              box_width = 400.0;
              cx = 540.0;
              cy = 1801.0;
              output = "DP-5";
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                input_opacity = 1.0;
                input_radius = 6.0;
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_password_hint = true;
              };
            };
            "lockscreen-login-box@HDMI-A-3" = {
              box_height = 70.0;
              box_width = 400.0;
              cx = 1536.0;
              cy = 1411.0;
              output = "HDMI-A-3";
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                input_opacity = 1.0;
                input_radius = 6.0;
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_password_hint = true;
              };
            };
            lockscreen-widget-0000000000000002 = {
              box_height = 96.0;
              box_width = 224.0;
              cx = 1404.0;
              cy = 1504.5;
              output = "HDMI-A-3";
              rotation = 0.0;
              type = "clock";
            };
            lockscreen-widget-0000000000000003 = {
              box_height = 96.0;
              box_width = 224.0;
              cx = 1664.0;
              cy = 1504.199951171875;
              output = "HDMI-A-3";
              rotation = 0.0;
              type = "weather";
            };
            lockscreen-widget-0000000000000004 = {
              box_height = 224.0;
              box_width = 224.0;
              cx = 1536.0;
              cy = 1248.0;
              output = "HDMI-A-3";
              rotation = 0.0;
              type = "fancy_audio_visualizer";
              settings = {
                background = false;
              };
            };
          };
        };
      };
      customPalettes = {
        colors = baseColors;
      };
    };
  };
}
