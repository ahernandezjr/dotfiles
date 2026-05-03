{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.browsers;

  # Central mapping of browser identifiers to their desktop file names.
  # Add new browsers here to extend support across the system.
  browserMapping = {
    brave = "brave-browser.desktop";
    floorp = "floorp.desktop";
    firefox = "firefox.desktop";
  };

  # Determine the primary browser ID. 
  # It uses the explicit 'default' if set, otherwise picks the first enabled one.
  primaryId =
    if cfg.default != "" then
      cfg.default
    else if cfg.brave.enable then
      "brave"
    else if cfg.floorp.enable then
      "floorp"
    else
      "firefox";

  activeDesktop = browserMapping.${primaryId} or "firefox.desktop";
in
{
  options.userSettings.browsers = {
    enable = lib.mkEnableOption "User browser configuration";

    default = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Default browser ID (brave, floorp, firefox). If empty, picks based on enabled browsers.";
    };

    activeDesktop = lib.mkOption {
      type = lib.types.str;
      default = activeDesktop;
      readOnly = true;
      description = "The desktop file name of the currently active browser.";
    };

    firefox.enable = lib.mkEnableOption "Enable Firefox browser";
    floorp.enable = lib.mkEnableOption "Enable Floorp browser";
    brave.enable = lib.mkEnableOption "Enable Brave browser";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER =
      if primaryId == "brave" then "brave" else primaryId;

    home.packages =
      (lib.optional cfg.firefox.enable pkgs.firefox)
      ++ (lib.optional cfg.floorp.enable pkgs.floorp-bin);
  };
}

