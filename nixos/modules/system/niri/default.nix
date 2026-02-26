{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.niri;
in
{
  options.systemSettings.niri = {
    enable = lib.mkEnableOption "Niri Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    # Use nixpkgs niri and NixOS cache instead of niri-flake cache.
    niri-flake.cache.enable = false;
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    environment.systemPackages = with pkgs; [ wl-clipboard ];
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.niri.package}/bin/niri-session";
          user = "alex";
        };
      };
    };
  };
}
