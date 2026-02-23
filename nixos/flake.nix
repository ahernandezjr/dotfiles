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
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays)
        ];
      };
      mkNixosSystem = profile: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${profile}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to home-manager
              backupFileExtension = "backup";
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        desktop = mkNixosSystem "desktop";
        laptop = mkNixosSystem "laptop";
        vm = mkNixosSystem "vm";
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
