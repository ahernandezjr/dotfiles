# Standalone Skyrim SE/AE Modding Suite Flake for NixOS
# Exposes GE-Proton10-34, Amethyst Mod Manager, Jackify, Wabbajack Curator,
# MO2 FHS wrapper, Skyrim Bethesda tools runner, NixOS system tuning, and Home Manager modules.
{
  description = "Skyrim SE/AE Modding Suite for NixOS (GE-Proton10-34, Amethyst, Jackify, Wabbajack Curator, MO2, Bethesda Tools Runner)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Exported package set for x86_64-linux
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        rec {
          # GloriousEggroll Proton GE 10-34 compatibility tool
          "ge-proton-10-34" = pkgs.callPackage ./pkgs/ge-proton-10-34 { };

          # Native Qt6/Rust Amethyst Mod Manager (v2.5.0)
          "amethyst-mod-manager" = pkgs.callPackage ./pkgs/amethyst-mod-manager { };

          # Native Wabbajack automated modlist installer
          jackify = pkgs.callPackage ./pkgs/jackify { };

          # Wabbajack Modlist Curator & Mod Comparison Tool
          "wabbajack-curator" = pkgs.callPackage ./pkgs/wabbajack-curator { };

          # Wine/Proton execution sandbox for Windows Bethesda modding tools
          "skyrim-tools-runner" = pkgs.callPackage ./pkgs/skyrim-tools-runner {
            ge-proton-10-34 = "ge-proton-10-34";
          };

          # Mod Organizer 2 launcher wrapper using GE-Proton10-34
          "mo2-fhs" = pkgs.callPackage ./pkgs/mo2-fhs {
            skyrim-tools-runner = "skyrim-tools-runner";
          };

          default = pkgs.callPackage ./pkgs/amethyst-mod-manager { };
        }
      );

      # Overlays to add skyrim tools directly to pkgs.<name>
      overlays.default = final: prev: {
        "ge-proton-10-34" = final.callPackage ./pkgs/ge-proton-10-34 { };
        "amethyst-mod-manager" = final.callPackage ./pkgs/amethyst-mod-manager { };
        jackify = final.callPackage ./pkgs/jackify { };
        "wabbajack-curator" = final.callPackage ./pkgs/wabbajack-curator { };
        "skyrim-tools-runner" = final.callPackage ./pkgs/skyrim-tools-runner {
          ge-proton-10-34 = final."ge-proton-10-34";
        };
        "mo2-fhs" = final.callPackage ./pkgs/mo2-fhs {
          skyrim-tools-runner = final."skyrim-tools-runner";
        };
      };

      # NixOS System Module (Kernel tuning, open file limits, steam mounts)
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        import ./modules/system.nix { inherit config lib pkgs; };
      nixosModules.skyrim = self.nixosModules.default;

      # Home Manager User Module (Packages, XDG shortcuts, nxm:// URL handler)
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        import ./modules/user.nix { inherit config lib pkgs; };
      homeManagerModules.skyrim = self.homeManagerModules.default;
    };
}
