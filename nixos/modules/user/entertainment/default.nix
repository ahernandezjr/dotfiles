{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.entertainment;
in
{
  options = {
    userSettings.entertainment = {
      enable = lib.mkEnableOption "Entertainment programs (Stremio, Waydroid)";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      stremio-linux-shell
    ];
  };
}
