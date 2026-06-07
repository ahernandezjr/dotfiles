{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.office;
in
{
  options = {
    userSettings.office = {
      enable = lib.mkEnableOption "Office and Document programs (LibreOffice, Calibre)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.libreoffice
      calibre
    ];
  };
}
