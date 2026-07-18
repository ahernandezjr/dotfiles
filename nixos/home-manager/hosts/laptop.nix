{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    noctalia.isPortable = true;
    gaming = {
      enable = true;
      sunshine.enable = true;
    };
    cuda.enable = true; # Enabled to match desktop NVIDIA focus
    editors.enable = true;
    communication.enable = true;
    utilities.enable = true;
    office.enable = true;
    entertainment.enable = true;
    productivity = {
      enable = true;
      onedrive.enable = true;
      teams.enable = true;
      zoom.enable = true;
      obsidian.enable = true;
    };
    niri.useDesktopOutputs = false; # Laptop screen focus
    niri.useWorkOutputs = true;
    browsers = {
      enable = true;
      firefox.enable = true;
      floorp.enable = true;
      brave.enable = true;
      default = "brave";
    };
  };

  home.packages = with pkgs; [
    networkmanager_dmenu
    pavucontrol
    wiremix
  ];
}
