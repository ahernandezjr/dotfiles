{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.xdg;
  home = config.home.homeDirectory;
in
{
  options = {
    userSettings.xdg = {
      enable = lib.mkEnableOption "Enable XDG user dirs and optional extra paths";
      desktop = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install desktop GUI utilities like nautilus, loupe, and screenshot tools";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ 
      p7zip
      unrar
    ] ++ lib.optionals cfg.desktop.enable [
      nautilus
      file-roller
      loupe
      grim
      slurp
      tesseract
      wl-clipboard
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

    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        search-view = "list-view";
        show-directory-item-counts = "always";
      };
      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
        default-visible-columns = [ "name" "size" "type" "date_modified" ];
      };
    };
  };
}
