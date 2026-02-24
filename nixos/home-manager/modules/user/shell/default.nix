{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  options = {
    userSettings.shell = {
      enable = lib.mkEnableOption "Enable shell (bash) and base CLI config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = {
        btw = "echo placeholder for future alias";
      };
    };
  };
}
