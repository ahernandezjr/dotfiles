{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.creativity;
in
{
  options = {
    userSettings.creativity = {
      enable = lib.mkEnableOption "Creativity tools (OrcaSlicer, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      orca-slicer
    ];
  };
}
