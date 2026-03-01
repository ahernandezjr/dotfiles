{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.niri;
in
{
  options.systemSettings.niri = {
    enable = lib.mkEnableOption "Niri Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    # Enable binary cache for niri.
    niri-flake.cache.enable = true;
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    environment.systemPackages = with pkgs; [ wl-clipboard ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Use systemd-cat for better logging. Sources Nix profile via bash -l.
          command = "${pkgs.bash}/bin/bash -l -c 'exec ${pkgs.systemd}/bin/systemd-cat --identifier=niri ${config.programs.niri.package}/bin/niri-session'";
          user = "alex";
        };
      };
    };
  };
}
