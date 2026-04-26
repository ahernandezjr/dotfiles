{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.browsers;
in
{
  options.userSettings.browsers = {
    enable = lib.mkEnableOption "User browser configuration";

    default = lib.mkOption {
      type = lib.types.enum [ "firefox" "floorp" "brave" ];
      default = "floorp";
      description = "Default browser to use";
    };

    firefox = {
      enable = lib.mkEnableOption "Enable Firefox browser";
    };

    floorp = {
      enable = lib.mkEnableOption "Enable Floorp browser";
    };

    brave = {
      enable = lib.mkEnableOption "Enable Brave browser";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER =
      if cfg.default == "brave" then "brave" else cfg.default;

    home.packages =
      (lib.optional cfg.firefox.enable pkgs.firefox)
      ++ (lib.optional cfg.floorp.enable pkgs.floorp-bin);

    # Set as default in XDG
    xdg.mimeApps.defaultApplications =
      let
        browserDesktop =
          if cfg.default == "brave" then
            "brave-browser.desktop"
          else if cfg.default == "floorp" then
            "floorp.desktop"
          else
            "firefox.desktop";
      in
      {
        "text/html" = browserDesktop;
        "x-scheme-handler/http" = browserDesktop;
        "x-scheme-handler/https" = browserDesktop;
        "x-scheme-handler/about" = browserDesktop;
        "x-scheme-handler/unknown" = browserDesktop;
      };
  };
}

