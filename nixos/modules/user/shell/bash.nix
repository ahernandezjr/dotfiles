{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "bash") (lib.mkMerge [
    { home.sessionVariables.SHELL = "${pkgs.bash}/bin/bash"; }
    (lib.mkIf cfg.manageConfig {
      programs.bash = {
        enable = true;
        shellAliases = {
          btw = "echo placeholder for future alias";
        };
      };
    })
  ]);
}
