{ lib }:

let
  # Recursively collect all entries under a directory, returning
  # relative paths like "niri/default.nix".
  getDir = dir:
    builtins.mapAttrs
      (name: type:
        if type == "directory"
        then getDir "${dir}/${name}"
        else type
      )
      (builtins.readDir dir);

  files = dir:
    lib.collect lib.isString
      (lib.mapAttrsRecursive
        (path: _type: lib.concatStringsSep "/" path)
        (getDir dir));
in
{
  # importAllDir { root = ./.; filter = relPath: <predicate>; }
  #
  # - root: directory whose .nix files you want to import.
  # - filter: predicate over the relative path ("subdir/file.nix").
  #
  # Returns a sorted list of importable paths under root that match filter.
  importAllDir = { root, filter ? (_: true) }:
    let
      relPaths = files root;
      selected = builtins.filter filter relPaths;
    in
    builtins.sort (a: b: a < b)
      (map (p: root + "/${p}") selected);
}

