# NixOS Configuration

This directory contains the NixOS configuration for multiple machines, structured to allow for easy management of different hardware profiles.

## Directory Structure

- `hosts/`: Contains the configuration for each individual machine.
  - `desktop/`: Configuration for the desktop machine.
    - `default.nix`: Imports the hardware-specific configuration and the common configuration.
    - `hardware-configuration.nix`: The hardware-specific configuration for the desktop.
  - `laptop/`: Configuration for the laptop machine.
    - `default.nix`: Imports the hardware-specific configuration and the common configuration.
    - `hardware-configuration.nix`: The hardware-specific configuration for the laptop.
  - `vm/`: Configuration for a virtual machine.
    - `default.nix`: Imports the hardware-specific configuration and the common configuration.
    - `hardware-configuration.nix`: The hardware-specific configuration for the VM.
- `common/`: Contains the common configuration shared across all machines.
- `home-manager/`: Contains the Home Manager configuration.
- `modules/`: Contains NixOS and Home Manager modules.
- `overlays/`: Contains package overlays.
- `pkgs/`: Contains custom packages.
- `flake.nix`: The flake configuration that builds the different systems, abstracting common settings.

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/ahernandezjr/dotfiles.git
   cd dotfiles/nixos
   ```

2. **Generate a new hardware configuration**

   Before you can build the system, you need to generate a hardware configuration file for your specific machine.

   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. **Move the configuration to the correct host directory**

   Move the generated `hardware-configuration.nix` file to the appropriate host directory. For example, if you are setting up the desktop:

   ```bash
   mv hardware-configuration.nix hosts/desktop/
   ```

   If you are setting up a new machine, you will need to create a new directory under `hosts` and add a `default.nix` that imports your new `hardware-configuration.nix` and the common configuration.

4. **Build the system**

   Now you can build the system using the following command. Replace `desktop` with the name of the host you are building for (e.g., `laptop`).

   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

## Development

- **Quick eval without rebuilding**

  From `nixos/`, you can evaluate a host’s system derivation to catch config errors without doing a full rebuild:

  ```bash
  nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath --no-warn-dirty
  ```

  For example, for the laptop profile:

  ```bash
  nix eval .#nixosConfigurations.laptop.config.system.build.toplevel.drvPath --no-warn-dirty
  ```
