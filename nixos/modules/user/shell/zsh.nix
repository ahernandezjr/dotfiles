{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "zsh") (lib.mkMerge [
    { home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh"; }
    (lib.mkIf cfg.manageConfig {
      programs.zsh = {
        enable = true;
        shellAliases = {
          btw = "echo placeholder for future alias";
        };
      };
    })
  ]);
}
