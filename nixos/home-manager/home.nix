{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
    ../modules/user
  ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "26.05";

  userSettings = {
    name = lib.mkDefault "Alexander Hernandez";
    email = lib.mkDefault "ahernandezjr0@gmail.com";
    development.enable = lib.mkDefault true;
    creativity.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    shell.enable = lib.mkDefault true;
    shell.manageConfig = lib.mkDefault true;
    browsers.enable = lib.mkDefault true;
    xdg.enable = lib.mkDefault true;
    niri.enable = lib.mkDefault true;
    noctalia.enable = lib.mkDefault true;
  };

  home.file.".config/vim/.vimrc".source = ./config/vim/.vimrc;
  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      segger-jlink.acceptLicense = true;
    }
  '';
}
