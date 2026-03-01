{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.browsers;
in
{
  options.userSettings.browsers = {
    enable = lib.mkEnableOption "User browser configuration";

    firefox = {
      enable = lib.mkEnableOption "Enable Firefox browser";
    };

    floorp = {
      enable = lib.mkEnableOption "Enable Floorp browser";
    };
  };

  config = lib.mkIf cfg.enable {
    # Prefer Floorp as the default browser.
    home.sessionVariables.BROWSER = "floorp";

    home.packages =
      (lib.optional cfg.firefox.enable pkgs.firefox)
      ++ (lib.optional cfg.floorp.enable pkgs.floorp-bin);
  };
}

