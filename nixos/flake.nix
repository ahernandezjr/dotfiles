{
  description = "Niri on Nixos Unstable (26.05 era)";

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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom-pkgs = {
      url = "git+file:///home/alex/dotfiles/nixos/pkgs-private";
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
      
      hostSystems = {
        pizero = "aarch64-linux";
      };

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          segger-jlink.acceptLicense = true;
          permittedInsecurePackages = [
            "pnpm-10.29.2"
          ];
        };
        overlays = [
          ourOverlays.additions
          ourOverlays.modifications
          ourOverlays.unstable-packages
          inputs.niri.overlays.niri
          inputs.millennium.overlays.default
          inputs.nix-cachyos-kernel.overlays.pinned
        ];
      };
      
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
      # Path to this repo on disk so matugen can write generated .nix into it (matugen-dots style).
      repoPath = "/home/alex/dotfiles";
      
      mkNixosSystem = profile:
        let
          hostSystem = hostSystems.${profile} or "x86_64-linux";
          pkgsForHost = if hostSystem == system then pkgs else import nixpkgs {
            system = hostSystem;
            config = {
              allowUnfree = true;
              segger-jlink.acceptLicense = true;
              permittedInsecurePackages = [
                "pnpm-10.29.2"
              ];
            };
            overlays = [
              ourOverlays.additions
              ourOverlays.modifications
              ourOverlays.unstable-packages
              inputs.niri.overlays.niri
              inputs.millennium.overlays.default
              inputs.nix-cachyos-kernel.overlays.pinned
            ];
          };
        in
        lib.nixosSystem {
          system = hostSystem;
          pkgs = pkgsForHost;
          specialArgs = { inherit inputs repoPath; };
          modules = [
            ./modules/system
            inputs.niri.nixosModules.niri
            inputs.agenix.nixosModules.default
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
          ] ++ lib.optionals (profile != "pizero") [
            inputs.custom-pkgs.nixosModules.default
          ];
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (map (host: { name = host; value = mkNixosSystem host; }) hosts);
      packages.${system} = pkgs;
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
