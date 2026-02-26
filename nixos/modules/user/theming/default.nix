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
  home.packages = [
    pkgs.matugen
    pkgs.qt6Packages.qt6ct
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
