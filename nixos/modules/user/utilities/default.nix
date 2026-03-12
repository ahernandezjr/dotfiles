{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.utilities;
in
{
  options = {
    userSettings.utilities = {
      enable = lib.mkEnableOption "Utility programs (baobab)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      baobab
    ];
  };
}
