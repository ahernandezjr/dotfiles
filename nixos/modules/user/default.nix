# Single entry for all Home Manager modules. home.nix imports this directory;
# we recursively pull in every .nix under here.
{ lib, ... }:

with lib;
let
  getDir = dir: mapAttrs
    (file: type:
      if type == "directory" then getDir "${dir}/${file}" else type
    )
    (builtins.readDir dir);

  files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Exclude partials (niri/*.nix) except their default.nix, and matugen template fragments.
  filtered = dir: filter
    (file:
      hasSuffix ".nix" file
      && file != "default.nix"
      && !(hasPrefix "niri/" file && file != "niri/default.nix")
      && !(hasPrefix "theming/templates/" file))
    (files dir);
  importAll = dir: map (file: ./. + "/${file}") (builtins.sort (a: b: a < b) (filtered dir));

in
{
  imports = importAll ./.;
}
