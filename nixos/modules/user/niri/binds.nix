# Keybinds (spawn = list; spawn-sh = string; Noctalia via noctalia "cmd")
{ config, lib, noctalia, term }: {
  binds = {
    "MOD+SHIFT+ESCAPE" = { action."show-hotkey-overlay" = [ ]; };

    # ─── System (Super + Any) ───
    "MOD+RETURN" = {
      hotkey-overlay.title = "Open Terminal: ghostty";
      action.spawn-sh = term;
    };
    "MOD+SPACE" = {
      hotkey-overlay.title = "Noctalia Launcher";
      action.spawn = noctalia "panel-toggle launcher";
    };
    "MOD+V" = {
      hotkey-overlay.title = "Clipboard History";
      action.spawn = noctalia "panel-toggle clipboard";
    };
    "MOD+ESCAPE" = {
      hotkey-overlay.title = "Session Menu";
      action.spawn = noctalia "panel-toggle session";
    };
    "MOD+W" = { action."close-window" = [ ]; };
    "MOD+TAB" = { action."focus-workspace-previous" = [ ]; };
    "MOD+O" = { repeat = false; action."toggle-overview" = [ ]; };
    "MOD+Q" = { action."toggle-column-tabbed-display" = [ ]; };
    "MOD+C" = { action."center-column" = [ ]; };
    "MOD+CTRL+C" = { action."center-visible-columns" = [ ]; };
    "MOD+1" = { action."focus-workspace" = 1; };
    "MOD+2" = { action."focus-workspace" = 2; };
    "MOD+3" = { action."focus-workspace" = 3; };
    "MOD+4" = { action."focus-workspace" = 4; };
    "MOD+5" = { action."focus-workspace" = 5; };
    "MOD+6" = { action."focus-workspace" = 6; };
    "MOD+7" = { action."focus-workspace" = 7; };
    "MOD+8" = { action."focus-workspace" = 8; };
    "MOD+9" = { action."focus-workspace" = 9; };

    # ─── Movement (Super + Shift + Any) ───
    "MOD+SHIFT+LEFT" = { action."move-column-left" = [ ]; };
    "MOD+SHIFT+RIGHT" = { action."move-column-right" = [ ]; };
    "MOD+SHIFT+UP" = { action."move-window-up" = [ ]; };
    "MOD+SHIFT+DOWN" = { action."move-window-down" = [ ]; };
    "MOD+SHIFT+h" = { action."move-column-left" = [ ]; };
    "MOD+SHIFT+l" = { action."move-column-right" = [ ]; };
    "MOD+SHIFT+k" = { action."move-window-up" = [ ]; };
    "MOD+SHIFT+j" = { action."move-window-down" = [ ]; };
    "MOD+SHIFT+HOME" = { action."move-column-to-first" = [ ]; };
    "MOD+SHIFT+END" = { action."move-column-to-last" = [ ]; };
    "MOD+SHIFT+1" = { action."move-column-to-workspace" = 1; };
    "MOD+SHIFT+2" = { action."move-column-to-workspace" = 2; };
    "MOD+SHIFT+3" = { action."move-column-to-workspace" = 3; };
    "MOD+SHIFT+4" = { action."move-column-to-workspace" = 4; };
    "MOD+SHIFT+5" = { action."move-column-to-workspace" = 5; };
    "MOD+SHIFT+6" = { action."move-column-to-workspace" = 6; };
    "MOD+SHIFT+7" = { action."move-column-to-workspace" = 7; };
    "MOD+SHIFT+8" = { action."move-column-to-workspace" = 8; };
    "MOD+SHIFT+9" = { action."move-column-to-workspace" = 9; };
    "MOD+SHIFT+P" = { action."power-off-monitors" = [ ]; };

    # ─── Programs (Super + Alt + Any) ───
    "MOD+ALT+B" = {
      hotkey-overlay.title = "Open Browser: brave";
      action.spawn-sh = "brave";
    };
    "MOD+ALT+F" = {
      hotkey-overlay.title = "File Manager: Nautilus";
      action.spawn-sh = "nautilus";
    };
    "MOD+ALT+Y" = {
      hotkey-overlay.title = "File Manager: yazi";
      action.spawn-sh = "${term} -e yazi";
    };
    "MOD+ALT+T" = {
      hotkey-overlay.title = "System Monitor: btop";
      action.spawn-sh = "${term} -e btop";
    };
    "MOD+ALT+N" = {
      hotkey-overlay.title = "Text Editor: nvim";
      action.spawn-sh = "${term} -e nvim";
    };
    "MOD+ALT+Z" = {
      hotkey-overlay.title = "Fuzzy Finder: fzf";
      action.spawn-sh = "${term} -e fish -c 'fzf'";
    };
    "MOD+ALT+D" = {
      hotkey-overlay.title = "LazyDocker";
      action.spawn-sh = "${term} -e lazydocker";
    };
    "MOD+ALT+A" = {
      hotkey-overlay.title = "ChatGPT";
      action.spawn-sh = "brave --app=https://chatgpt.com";
    };
    "MOD+ALT+W" = {
      hotkey-overlay.title = "Trello";
      action.spawn-sh = "brave --app=https://trello.com";
    };
    "MOD+ALT+E" = {
      hotkey-overlay.title = "Excalidraw";
      action.spawn-sh = "excalidraw";
    };
    "MOD+ALT+M" = {
      hotkey-overlay.title = "Stremio";
      action.spawn-sh = "stremio";
    };
    "MOD+ALT+G" = {
      hotkey-overlay.title = "Vesktop (Discord)";
      action.spawn-sh = "vesktop";
    };
    "MOD+ALT+SPACE" = {
      hotkey-overlay.title = "Noctalia Control Center";
      action.spawn = noctalia "panel-toggle control-center";
    };
    "MOD+ALT+S" = {
      hotkey-overlay.title = "Noctalia Settings";
      action.spawn = noctalia "settings-toggle";
    };

    # ─── Monitor (Super + Shift + Alt + Any) ───
    "MOD+SHIFT+ALT+LEFT" = { action."move-column-to-monitor-left" = [ ]; };
    "MOD+SHIFT+ALT+RIGHT" = { action."move-column-to-monitor-right" = [ ]; };
    "MOD+SHIFT+ALT+UP" = { action."move-window-to-monitor-up" = [ ]; };
    "MOD+SHIFT+ALT+DOWN" = { action."move-window-to-monitor-down" = [ ]; };
    "MOD+SHIFT+ALT+h" = { action."move-column-to-monitor-left" = [ ]; };
    "MOD+SHIFT+ALT+l" = { action."move-column-to-monitor-right" = [ ]; };
    "MOD+SHIFT+ALT+k" = { action."move-window-to-monitor-up" = [ ]; };
    "MOD+SHIFT+ALT+j" = { action."move-window-to-monitor-down" = [ ]; };

    # ─── Focus & Navigation (Keep some MOD+Any for core movement) ───
    "MOD+LEFT" = { action."focus-column-left" = [ ]; };
    "MOD+H" = { action."focus-column-left" = [ ]; };
    "MOD+RIGHT" = { action."focus-column-right" = [ ]; };
    "MOD+L" = { action."focus-column-right" = [ ]; };
    "MOD+UP" = { action."focus-window-up" = [ ]; };
    "MOD+K" = { action."focus-window-up" = [ ]; };
    "MOD+DOWN" = { action."focus-window-down" = [ ]; };
    "MOD+J" = { action."focus-window-down" = [ ]; };

    "MOD+ALT+LEFT" = { action."focus-monitor-left" = [ ]; };
    "MOD+ALT+RIGHT" = { action."focus-monitor-right" = [ ]; };
    "MOD+ALT+UP" = { action."focus-monitor-up" = [ ]; };
    "MOD+ALT+DOWN" = { action."focus-monitor-down" = [ ]; };
    "MOD+ALT+h" = { action."focus-monitor-left" = [ ]; };
    "MOD+ALT+l" = { action."focus-monitor-right" = [ ]; };
    "MOD+ALT+k" = { action."focus-monitor-up" = [ ]; };
    "MOD+ALT+j" = { action."focus-monitor-down" = [ ]; };

    "MOD+HOME" = { action."focus-column-first" = [ ]; };
    "MOD+END" = { action."focus-column-last" = [ ]; };
    "MOD+COMMA" = { action."consume-window-into-column" = [ ]; };
    "MOD+PERIOD" = { action."expel-window-from-column" = [ ]; };

    # ─── Scroll & Mouse ───
    "MOD+WHEELSCROLLDOWN" = { cooldown-ms = 150; action."focus-workspace-down" = [ ]; };
    "MOD+WHEELSCROLLUP" = { cooldown-ms = 150; action."focus-workspace-up" = [ ]; };
    "MOD+CTRL+WHEELSCROLLDOWN" = { cooldown-ms = 150; action."move-column-to-workspace-down" = [ ]; };
    "MOD+CTRL+WHEELSCROLLUP" = { cooldown-ms = 150; action."move-column-to-workspace-up" = [ ]; };
    "MOD+WHEELSCROLLRIGHT" = { action."focus-column-right" = [ ]; };
    "MOD+WHEELSCROLLLEFT" = { action."focus-column-left" = [ ]; };

    # ─── Layout & Appearance ───
    "MOD+CTRL+F" = { action."expand-column-to-available-width" = [ ]; };
    "MOD+MINUS" = { action."set-column-width" = "-10%"; };
    "MOD+EQUAL" = { action."set-column-width" = "+10%"; };
    "MOD+SHIFT+MINUS" = { action."set-window-height" = "-10%"; };
    "MOD+SHIFT+EQUAL" = { action."set-window-height" = "+10%"; };
    "MOD+F11" = { action."fullscreen-window" = [ ]; };
    "MOD+CTRL+SPACE" = {
      hotkey-overlay.title = "Toggle Wallpaper Selector";
      action.spawn = noctalia "panel-toggle wallpaper";
    };

    # ─── QoL & OCR (Grim/Slurp/Tesseract) ───
    "MOD+CTRL+PRINT" = {
      hotkey-overlay.title = "OCR to Clipboard";
      action.spawn-sh = "grim -g \"$(slurp)\" - | tesseract - - | wl-copy";
    };
    "PRINT" = {
      hotkey-overlay.title = "Screenshot: Noctalia";
      action.spawn-sh = "niri msg action screenshot";
    };
    "SHIFT+PRINT" = {
      hotkey-overlay.title = "Screenshot: Active Window";
      action.spawn-sh = "grim -g \"$(slurp -r)\" ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png && wl-copy < ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png";
    };

    # ─── Media & Hardware ───
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };
    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn-sh = "brightnessctl set 5%+";
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn-sh = "brightnessctl set 5%-";
    };
    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn = noctalia "volume-up";
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn = noctalia "volume-down";
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn = noctalia "volume-mute";
    };
    "XF86AudioNext" = {
      allow-when-locked = true;
      action.spawn = noctalia "media next";
    };
    "XF86AudioPause" = {
      allow-when-locked = true;
      action.spawn = noctalia "media stop";
    };
    "XF86AudioPlay" = {
      allow-when-locked = true;
      action.spawn = noctalia "media play";
    };
    "XF86AudioPrev" = {
      allow-when-locked = true;
      action.spawn = noctalia "media previous";
    };

    # ─── Emergency ───
    "MOD+CTRL+ALT+DELETE" = {
      allow-inhibiting = false;
      action."toggle-keyboard-shortcuts-inhibit" = [ ];
    };
    "CTRL+ALT+DELETE" = { action.quit = [ ]; };
  };
}
