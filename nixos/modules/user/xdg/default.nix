{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.xdg;
  home = config.home.homeDirectory;
in
{
  options = {
    userSettings.xdg = {
      enable = lib.mkEnableOption "Enable XDG user dirs and optional extra paths";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ 
      nautilus
      file-roller
      p7zip
      unrar
    ];
    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      documents = "${home}/Documents";
      download = "${home}/Downloads";
      music = "${home}/Music";
      pictures = "${home}/Pictures";
      videos = "${home}/Videos";
      desktop = null;
      publicShare = null;
      extraConfig = {
        ARCHIVE = "${home}/Archive";
        DOTFILES = "${home}/.dotfiles";
      };
    };
  };
}
