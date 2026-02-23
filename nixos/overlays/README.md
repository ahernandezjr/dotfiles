This directory contains NixOS overlays. Overlays are used to add new packages or to modify existing ones. See the [NixOS Wiki on Overlays](https://nixos.wiki/wiki/Overlays) for more information.

This configuration is structured to support three common overlay patterns:

1.  **`additions`**: This overlay is used to add custom packages from the `pkgs` directory to your Nixpkgs set.

2.  **`modifications`**: This overlay is for making changes to existing packages. You can use it to change package versions, apply patches, or set compilation flags.

3.  **`unstable-packages`**: This overlay demonstrates how to make packages from the unstable Nixpkgs channel available in your configuration (as `pkgs.unstable`). This is useful when you need a newer version of a specific package without switching your entire system to the unstable channel.