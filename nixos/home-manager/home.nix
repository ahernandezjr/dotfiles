{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/user
    ./modules/niri.nix
    ./modules/noctalia.nix
  ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  userSettings = {
    name = "Alexander Hernandez";
    email = "ahernandezjr0@gmail.com";
    git.enable = true;
    shell.enable = true;
  };

  home.file.".config/vim/.vimrc".source = ./config/vim/.vimrc;
}
