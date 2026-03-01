{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    gaming.enable = true;
    cuda.enable = true;
    editors.enable = true;
    communication.enable = true;
    niri.useDesktopOutputs = true;
    browsers = {
      enable = true;
      firefox.enable = true;
      floorp.enable = true;
    };
  };

  home.packages = with pkgs; [
    networkmanager_dmenu
    pavucontrol
    wiremix
  ];
}
