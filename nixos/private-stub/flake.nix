{
  description = "Private packages placeholder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = _: {
    overlays.default = final: prev: { };
    nixosModules.default = { ... }: { };
  };
}
