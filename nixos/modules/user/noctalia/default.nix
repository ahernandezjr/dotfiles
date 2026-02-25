# Noctalia-shell: Home Manager config using native options (Configuration Defaults schema).
# Config files are linked to dotfiles via mkOutOfStoreSymlink to remain writable.
{ config, inputs, lib, ... }:

let
  home = config.home.homeDirectory;
  # Points to the writable dotfiles on disk.
  dotfilesNoctalia = "${home}/dotfiles/config/noctalia";
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = {
    # Disable HM module's automatic file generation to avoid Nix store read-only symlinks
    xdg.configFile."noctalia/settings.json".enable = lib.mkForce false;
    xdg.configFile."noctalia/colors.json".enable = lib.mkForce false;
    xdg.configFile."noctalia/plugins.json".enable = lib.mkForce false;
    xdg.configFile."noctalia/user-templates.toml".enable = lib.mkForce false;

    # Previously used to override Stylix's GTK CSS; with Stylix removed, disable this file.
    xdg.configFile."gtk-3.0/gtk.css".enable = lib.mkForce false;

    # Manually link them to the dotfiles directory (writable)
    home.file = {
      ".config/noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesNoctalia}/settings.json";
      ".config/noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesNoctalia}/colors.json";
      ".config/noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesNoctalia}/plugins.json";
      ".config/noctalia/user-templates.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesNoctalia}/user-templates.toml";
    };

    programs.noctalia-shell = {
      enable = true;
      # No 'settings' here; the app uses the symlinked files above as source of truth.
    };
  };
}
