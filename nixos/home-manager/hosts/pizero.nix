{ lib, ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    browsers.enable = false;
    creativity.enable = false;
    development.enable = false;
    niri.enable = false;
    noctalia.enable = false;
    xdg.desktop.enable = false;
  };
}
