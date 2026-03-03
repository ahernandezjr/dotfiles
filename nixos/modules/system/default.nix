# Single entry for all NixOS modules. Flake imports this directory; we use a
# helper to recursively pull in every .nix under here so hosts never need
# ../../ paths to modules.
{ lib, ... }:

let
  moduleLib = import ../../lib/import-all.nix { inherit lib; };
in
{
  imports = moduleLib.importAllDir {
    root = ./.;
    filter = file: lib.hasSuffix ".nix" file && file != "default.nix";
  };
}
