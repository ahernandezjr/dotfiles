# Theming-related packages: Matugen (Material You palette generator) for apps
# that consume it (e.g. Noctalia Steam theme "Matugen" color option).
# Stylix is configured in modules/system/stylix.nix.
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ matugen ];
}
