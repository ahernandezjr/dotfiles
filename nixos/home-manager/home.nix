{ config, pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  programs = {

    bash = {
      enable = true;
      shellAliases = {
        btw = "echo placeholder for future alias";
      };
    };

    git = {
      enable = true;
      settings.user = {
        name = "Alexander Hernandez";
        email = "ahernandezjr0@gmail.com";
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };

    home.file.".config/vim/.vimrc".source = ./config/vim/.vimrc;
    # home.file.".config/xxx".source = ./config/xxx;
  };
}
