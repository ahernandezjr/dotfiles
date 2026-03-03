# Single entry for all Home Manager modules. home.nix imports this directory;
# we use a helper to recursively pull in every .nix under here.
{ lib, ... }:

with lib;
let
  moduleLib = import ../../lib/import-all.nix { inherit lib; };
  # Exclude partials (niri/*.nix) except their default.nix, and matugen template fragments.
  filter = file:
    hasSuffix ".nix" file
    && file != "default.nix"
    && !(hasPrefix "niri/" file && file != "niri/default.nix")
    && !(hasPrefix "theming/templates/" file);
in
{
  imports = moduleLib.importAllDir {
    root = ./.;
    filter = filter;
  };
}
