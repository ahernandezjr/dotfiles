{
  description = "Private packages placeholder";
  outputs = _: {
    overlays.default = final: prev: { };
    nixosModules.default = { ... }: { };
  };
}
