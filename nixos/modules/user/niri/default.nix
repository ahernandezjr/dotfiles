# Niri user config: programs.niri.settings from split files.
# See https://github.com/sodiboo/niri-flake/blob/main/docs.md
{ config, lib, pkgs, ... }:

let
  noctalia = cmd:
    [ "noctalia-shell" "ipc" "call" ]
    ++ (lib.splitString " " cmd);
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
  # matugen-dots style: matugen writes a .nix file into the repo; we import it if present.
  matugenColorsPath = ./. + "/matugen-colors.nix";
  matugenColorsSettings = let
    raw = if builtins.pathExists matugenColorsPath then import matugenColorsPath else {};
  in raw.programs.niri.settings or {};
in
{
  options.userSettings.niri.useDesktopOutputs = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Use the desktop multi-monitor output config for the external Dell (DP-3), INNOCN 32M2V (HDMI-A-3), and BenQ XL2420TE (DP-5) monitors. When false, niri auto-detects (single display for laptop/vm).";
  };

  config = {
    # The niri-flake home-manager module (homeModules.config) uses xdg.configFile.niri-config.
    # We override it to add our noctalia.kdl include.
    # We use lib.mkForce to ensure we override the module's own definition.
    xdg.configFile.niri-config = lib.mkForce {
      target = "niri/config.kdl";
      source = pkgs.runCommand "niri-config-with-noctalia" {
        baseConfig = config.programs.niri.finalConfig;
      } ''
        echo "$baseConfig" > config.kdl
        echo 'include "./noctalia.kdl"' >> config.kdl
        cp config.kdl $out
      '';
    };

    programs.niri.settings = lib.mkMerge ([
      (import ./input.nix { inherit lib; })
      (import ./binds.nix { inherit config lib noctalia term; })
      (import ./layout.nix { inherit lib config; })
      (import ./animations.nix { inherit lib; })
      (import ./rules.nix { inherit lib; })
      (import ./misc.nix { inherit config lib term; })
      matugenColorsSettings
    ] ++ outputsFragment ++ [{
      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite;
      };
    }]);
  };
}
