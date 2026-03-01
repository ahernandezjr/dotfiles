{ config, pkgs, repoPath ? "/home/alex/dotfiles", ... }:

let
  wallpaper = "${repoPath}/images/wallpaper.jpg";
  # matugen-dots style: template is a .nix fragment; matugen fills placeholders and writes to repo.
  niriNixTemplate = ''
    {
      programs.niri.settings = {
        layout.focus-ring.active.gradient = {
          from = "{{ colors.primary.default.hex }}";
          to = "#ffffff";
          angle = 135;
        };
        layout.shadow.color = "{{ colors.shadow.default.hex }}70";
      };
    }
  '';
  niriOutputPath = "${repoPath}/nixos/modules/user/niri/matugen-colors.nix";
in {
  home.pointerCursor = {
    name = "Vimix-cursors";
    package = pkgs.vimix-cursors;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = config.home.pointerCursor.name;
      package = config.home.pointerCursor.package;
      size = config.home.pointerCursor.size;
    };
  };

  home.packages = [
    pkgs.matugen
    pkgs.qt6Packages.qt6ct
    pkgs.bibata-cursors
    pkgs.material-cursors
    pkgs.lyra-cursors
    pkgs.capitaine-cursors
  ];

  xdg.configFile = {
    "matugen/templates/niri.nix".text = niriNixTemplate;
    "matugen/config.toml".text = ''
      [config]
      [templates.niri]
      input_path = "~/.config/matugen/templates/niri.nix"
      output_path = "${niriOutputPath}"
      post_hook = "niri msg action load-config-file"
    '';
  };

  home.activation.run-matugen = ''
    ${pkgs.matugen}/bin/matugen image ${wallpaper} 2>/dev/null || true
  '';
}
