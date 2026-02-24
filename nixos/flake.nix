{
  description = "Niri on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Provides access to unstable packages, see overlays/default.nix
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays)
        ];
      };
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
      # Single module tree: ./modules/system/default.nix recursively imports all .nix under it.
      # Hosts only set options (e.g. systemSettings.niri.enable), no ../../ paths.
      mkNixosSystem = profile: lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/system
          ./hosts/${profile}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex = import ./home-manager/hosts/${profile}.nix;
              extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to home-manager
              backupFileExtension = "backup";
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = builtins.listToAttrs (map (host: { name = host; value = mkNixosSystem host; }) hosts);
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
