{ config, pkgs, ... }:

{
  config = {
    nix = {
      package = pkgs.nix;
      settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = [ "@wheel" ];
        auto-optimise-store = true;
        download-buffer-size = 500000000;
        experimental-features = [ "nix-command" "flakes" ];
      };
    };
    programs.nix-ld = {
      enable = true;
      libraries = [
        pkgs.stdenv.cc.cc
        pkgs.zlib
        pkgs.fuse3
        pkgs.icu
        pkgs.nss
        pkgs.openssl
        pkgs.curl
        pkgs.expat
        pkgs.libx11
        pkgs.vulkan-headers
        pkgs.vulkan-loader
        pkgs.vulkan-tools
      ];
    };
  };
}
