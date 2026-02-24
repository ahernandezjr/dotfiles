{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.niri;
in
{
  options.systemSettings.niri = {
    enable = lib.mkEnableOption "Niri Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.niri}/bin/niri";
          user = "alex";
        };
      };
    };
  };
}
