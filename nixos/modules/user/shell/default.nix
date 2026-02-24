{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  options = {
    userSettings.shell = {
      enable = lib.mkEnableOption "Enable shell and base CLI config";
      type = lib.mkOption {
        default = "fish";
        type = lib.types.enum [ "bash" "zsh" "fish" ];
        description = "Login shell to use";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Shared CLI bits can go here (e.g. home.packages with direnv)
  };
}
