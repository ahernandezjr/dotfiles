# Mangowc: lightweight Wayland compositor (dwl-based).
{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.mangowc;
in
{
  options.systemSettings.mangowc = {
    enable = lib.mkEnableOption "Mangowc Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mangowc ];
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.mangowc}/bin/mango";
          user = "alex";
        };
      };
    };
  };
}
