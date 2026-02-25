# Niri user config: programs.niri.settings from split files.
# See https://github.com/sodiboo/niri-flake/blob/main/docs.md
{ config, lib, pkgs, ... }:

let
  noctalia = cmd: [ "noctalia-shell" "ipc" "call" ] ++ (lib.splitString " " cmd);
  term = config.home.sessionVariables.TERMINAL or "ghostty";
  parseMode = s:
    let
      m = builtins.match "([0-9]+)x([0-9]+)@([0-9.]+)" s;
    in
    if m == null then null else {
      width = builtins.fromJSON (builtins.elemAt m 0);
      height = builtins.fromJSON (builtins.elemAt m 1);
      refresh = (builtins.fromJSON (builtins.elemAt m 2)) + 0.0;
    };
  useDesktopOutputs = config.userSettings.niri.useDesktopOutputs;
  outputsFragment = lib.optional useDesktopOutputs (import ./outputs.nix { inherit lib parseMode; });
in
{
  options.userSettings.niri.useDesktopOutputs = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Use the desktop multi-monitor output config (DP-3, HDMI-A-1, DP-1). When false, niri auto-detects (single display for laptop/vm).";
  };

  config = {
    programs.niri.settings = lib.mkMerge ([
      (import ./input.nix { inherit lib; })
      (import ./binds.nix { inherit config lib noctalia term; })
      (import ./layout.nix { inherit lib; })
      (import ./animations.nix { inherit lib; })
      (import ./rules.nix { inherit lib; })
      (import ./misc.nix { inherit config lib term; })
    ] ++ outputsFragment ++ [{
      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite;
      };
    }]);
  };
}
