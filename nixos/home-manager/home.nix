{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
    ../modules/user
  ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "26.05";

  userSettings = {
    name = "Alexander Hernandez";
    email = "ahernandezjr0@gmail.com";
    development.enable = true;
    git.enable = true;
    shell.enable = true;
    shell.manageConfig = true;
    xdg.enable = true;
  };

  home.file.".config/vim/.vimrc".source = ./config/vim/.vimrc;
  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      segger-jlink.acceptLicense = true;
    }
  '';
}
