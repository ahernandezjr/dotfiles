{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.git;
in
{
  options = {
    userSettings.git = {
      enable = lib.mkEnableOption "Enable git and gh";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.git = {
      enable = true;
      settings = {
        url."https://github.com/".insteadOf = [
          "gh:"
          "github:"
        ];
        user = {
          name = config.userSettings.name;
          email = config.userSettings.email;
        };
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
