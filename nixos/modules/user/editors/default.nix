{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userSettings.editors;
in
{
  options.userSettings.editors = {
    enable = lib.mkEnableOption "Editors (Cursor, VSCode, Neovim) and their plugins";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      inputs.cursor.packages.x86_64-linux.cursor
      vscode
    ];

    # Central place for editor configuration and plugins.
    programs.vscode = {
      enable = true;
      # Add VSCode extensions here, e.g.:
      # extensions = [ pkgs.vscode-extensions.<publisher>.<name> ];
    };

    programs.neovim = {
      enable = true;
      # Add Neovim plugins here, e.g.:
      # plugins = [ pkgs.vimPlugins.<plugin-name> ];
    };
  };
}


