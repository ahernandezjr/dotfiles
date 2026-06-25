{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Bootstraps the SD card image builder
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pizero";
  nixpkgs.hostPlatform = "aarch64-linux";

  # Enable minimal CLI system profile (keeps fish, gh, jq, git, etc.)
  systemSettings.minimal.enable = true;

  # Enable services
  systemSettings.tailscale.enable = true;
  systemSettings.obsidian = {
    enable = true;
    passwordFile = config.age.secrets.obsidian-password.path;
    vaultPath = "/home/alex/Shared/ObsidianVault";
  };

  # Swap file: prevents OOM panics when running containerized applications
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2048; # 2GB
  } ];

  # NetworkManager Wi-Fi configuration
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    "home-wifi" = {
      connection = {
        id = "home-wifi";
        type = "wifi";
        uuid = "8a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "YourSSID"; # Replace with your Wi-Fi SSID
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "YourWiFiPassword"; # Replace with your Wi-Fi Password
      };
    };
  };

  # SSH Access & Authorized Keys
  services.openssh.enable = true;
  users.users.alex.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUe5G6o++8ueJzhj/vuD3phcdtQi2Mz4ReIol4sAEyw ahernandezjr0@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEchyWdEd4/47h1EpU40Vr5sGC8/L89THzamj1GxLgZ ahernandezjr0@gmail.com"
  ];

  # Agenix Secrets Configuration
  age.secrets.obsidian-password = {
    file = ../../secrets/obsidian-password.age;
    owner = "alex";
  };

  # Fast SD building (skip compression)
  sdImage.compressImage = false;
  documentation.enable = false;
}
