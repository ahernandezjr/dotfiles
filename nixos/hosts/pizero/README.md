# Raspberry Pi Zero 2 W Setup Guide

This profile configures a headless, minimal NixOS system for the Pi Zero 2 W. It runs your terminal config, configures Tailscale, and hosts a password-secured Obsidian container synced via Syncthing.

---

## 1. Initial Build & Flash (from Workstation)

First, make sure you rebuild your desktop configuration so it enables `binfmt` emulation for compiling `aarch64` binaries:
```bash
sudo nixos-rebuild switch --flake .#desktop
```

Next, build the bootable SD card image:
```bash
nix build .#nixosConfigurations.pizero.config.system.build.sdImage
```

Flash the generated image found at `./result/sd-image/nixos-sd-image-...img` to your micro SD card using the **Raspberry Pi Imager** or `dd`.

---

## 2. Boot & Grab the SSH Host Key

1. Put the SD card in the Pi Zero 2 W and power it on. It will automatically connect to your Wi-Fi (configured in `hosts/pizero/default.nix`) and generate its SSH host keys.
2. Find the Pi's IP address (e.g. via router interface or scanning your network).
3. SSH into the Pi (using your default SSH key):
   ```bash
   ssh alex@<pi-zero-ip>
   ```
4. Grab the Pi's public SSH host key:
   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

---

## 3. Rekey Secrets with Agenix

On your workstation:

1. Add the Pi's host key to [secrets.nix](../../secrets.nix):
   ```nix
   pizero = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...";
   ```
2. Include `pizero` in the public keys list for `secrets/syncthing-password.age` and create a new `secrets/obsidian-password.age` file containing the environment variable for your Obsidian VNC password:
   ```bash
   # In secrets/obsidian-password.age (edit it using your agenix command):
   PASSWORD=your_vnc_web_password
   ```
3. Rekey the secrets to encrypt them for the new host:
   ```bash
   agenix -r
   ```
4. Commit the changes to your dotfiles Git repo:
   ```bash
   git add .
   git commit -m "pi-zero: add host config and secrets"
   ```

---

## 4. Push Configurations & Start Tailscale

1. Deploy the final configuration from your workstation (this will push and activate the Obsidian container and secrets):
   ```bash
   nixos-rebuild switch --flake .#pizero --target-host alex@<pi-zero-ip> --use-remote-sudo
   ```
2. Log into the Pi over SSH and authenticate Tailscale:
   ```bash
   ssh alex@<pi-zero-ip> "sudo tailscale up"
   ```

You can now connect to your Obsidian editor from anywhere in your tailnet by navigating to `http://<tailscale-ip>:8080`!
