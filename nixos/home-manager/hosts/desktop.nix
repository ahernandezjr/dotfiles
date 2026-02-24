{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    gaming.enable = true;
    cuda.enable = true;
    niri.useDesktopOutputs = true;
  };

  home.packages = with pkgs; [
    networkmanager_dmenu
    pavucontrol
    wiremix
  ];
}
