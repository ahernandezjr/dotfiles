{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.cuda;
in
{
  options = {
    userSettings.cuda = {
      enable = lib.mkEnableOption "Enable CUDA-related packages and config";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Add CUDA packages as needed when NixOS config provides them
    ];
  };
}
