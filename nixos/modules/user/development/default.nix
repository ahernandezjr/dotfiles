# Development tools: Python, uv. Enable via userSettings.development.enable.
{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.development;
in
{
  options.userSettings.development = {
    enable = lib.mkEnableOption "Development tools (Python, uv)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Languages and Libraries
      python3
      uv

      # Other
    ];
  };
}
