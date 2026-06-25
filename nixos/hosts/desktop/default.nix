{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "desktop";

  users.users.alex.extraGroups = [ "gamemode" ];

  swapDevices = [ { device = "/swap/swapfile"; } ];

  boot.resumeDevice = "/dev/disk/by-uuid/00f2da24-f381-4e2b-9c26-6826b111dc3e";
  boot.kernelParams = [ "resume_offset=88614144" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  systemSettings = {
    docker = {
      enable = true;
      containers = {
        qbittorentvpn.enable = true;
        localai.enable = false;
        dnd-kit.enable = true;
      };
    };
    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
    gaming = {
      enable = true;
      sunshine.enable = true;
    };
    vfio.enable = true;
    cachyos-kernel.enable = true;
    browsers.brave.enable = true;
    virtualization.waydroid.enable = true;
    drivers.peripherals.enable = true;
  };
}
