{
  description = "Niri on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # Backup name for access to unstable packages, see overlays/default.nix
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen = {
      url = "github:InioX/Matugen";
      # ref = "refs/tags/matugen-v0.10.0";
    };

    # Gamescope helpers (ScopeBuddy, etc.)
    just-one-more-repo = {
      url = "github:ProverbialPennance/just-one-more-repo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    # Local nixpkgs clone; only packages listed in nixpkgs-dev-config.nix use this until PR is merged.
    # nixpkgs-dev.url = "path:/home/alex/repos/nixpkgs-dev";
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
      nixpkgsDevConfig = import ./nixpkgs-dev-config.nix;
      ourOverlays = import ./overlays { inherit inputs; };
      # overlayNixpkgsDev = final: prev:
      #  lib.genAttrs nixpkgsDevConfig.packageNames
      #    (name: inputs.nixpkgs-dev.legacyPackages.${prev.system}.${name});
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          segger-jlink.acceptLicense = true;
        };
        overlays = [
          ourOverlays.additions
          ourOverlays.modifications
          ourOverlays.unstable-packages
          inputs.niri.overlays.niri
          inputs.millennium.overlays.default
          inputs.nix-cachyos-kernel.overlays.pinned
        ] ++ (lib.optionals nixpkgsDevConfig.enable [ ]);
      };
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
      # Path to this repo on disk so matugen can write generated .nix into it (matugen-dots style).
      repoPath = "/home/alex/dotfiles";
      mkNixosSystem = profile: lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs repoPath; };
        modules = [
          ./modules/system
          inputs.niri.nixosModules.niri
          ./hosts/${profile}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex = import ./home-manager/hosts/${profile}.nix;
              extraSpecialArgs = { inherit inputs repoPath; };
              backupFileExtension = "hmbkp";
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
