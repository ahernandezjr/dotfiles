{ config, pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";
  
  programs.git = {
	enable = true;
	settings.user = {
		name = "Alexander Hernandez";
		email = "ahernandezjr0@gmail.com";
	};
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo placeholder for future alias";
    };
  };

  # home.file.".config/xxx".source = ./config/xxx;
}
