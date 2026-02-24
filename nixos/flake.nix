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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    stylix = {
      url = "github:nix-community/stylix";
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
      ourOverlays = import ./overlays { inherit inputs; };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          ourOverlays.additions
          ourOverlays.modifications
          ourOverlays.unstable-packages
          inputs.niri.overlays.niri
          inputs.millennium.overlays.default
        ];
      };
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
      # Single module tree: ./modules/system/default.nix recursively imports all .nix under it.
      # Hosts only set options (e.g. systemSettings.niri.enable), no ../../ paths.
      mkNixosSystem = profile: lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/system
          inputs.niri.nixosModules.niri
          inputs.stylix.nixosModules.stylix
          ./hosts/${profile}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex = import ./home-manager/hosts/${profile}.nix;
              extraSpecialArgs = { inherit inputs; dotfilesNoctalia = ../config/noctalia; };
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
