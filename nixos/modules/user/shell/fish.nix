{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "fish") {
    programs.fish = {
      enable = true;
      shellAliases = {
        btw = "echo placeholder for future alias";
      };
    };
    home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
  };
}
