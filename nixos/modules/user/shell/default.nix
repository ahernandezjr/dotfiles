{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  options = {
    userSettings.shell = {
      enable = lib.mkEnableOption "Enable shell and base CLI config";
      type = lib.mkOption {
        default = "fish";
        type = lib.types.enum [ "bash" "zsh" "fish" ];
        description = "Login shell to use";
      };
      manageConfig = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "When true, Home Manager manages shell config (programs.fish/zsh/bash). When false, only SHELL and package are set; existing dotfiles are used.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.ghostty = {
        enable = true;
        settings = {
          theme = "noctalia";
	  background-opacity = 0.85;
        };
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        options = [ "--cmd cd" ];
      };
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        defaultCommand = "fd --type f";
        defaultOptions = [ "--height 40%" "--layout=reverse-list" "--border" ];
        fileWidgetCommand = "fd --type f";
        changeDirWidgetCommand = "fd --type d";
        tmux.enableShellIntegration = true;
        tmux.shellIntegrationOptions = [ "-d 40%" ];
      };
      programs.bat = {
        enable = true;
        config = {
          pager = "less -FR";
        };
      };
      programs.tmux = {
        enable = true;
        mouse = true;
        baseIndex = 1;
        sensibleOnTop = true;
        terminal = "tmux-256color";
        newSession = true;
        historyLimit = 5000;
      };
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        settings = { scan_timeout = 10; };
      };
      programs.nushell = {
        enable = true;
        settings = { show_banner = false; };
      };
      home.packages = with pkgs; [
        btop
        eza
        fd
        lazygit
        lazydocker
        neofetch
        ripgrep
      ];
    }
  ]);
}
