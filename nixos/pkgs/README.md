This directory is for custom packages, which can be defined similarly to packages in the main Nixpkgs repository. See the [NixOS Wiki on Packaging](https://nixos.wiki/wiki/Packaging) for more detailed instructions.

### Defining a Package

To add a new package, you would typically create a new directory and a `default.nix` file within it (e.g., `pkgs/my-package/default.nix`). Then, you would reference it from the `default.nix` in this directory:

```nix
pkgs: {
  my-package = pkgs.callPackage ./my-package { };
}
```

### Building a Package

You can build a package defined here directly from your flake root using the `nix build` command. For example, to build the `my-package` example above, you would run:

```sh
nix build .#my-package
```