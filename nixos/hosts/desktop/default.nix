{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "desktop";

  users.users.alex.extraGroups = [ "gamemode" ];

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
    gaming.enable = true;
    vfio.enable = true;
    cachyos-kernel.enable = true;
    browsers.brave.enable = true;
    drivers.peripherals.enable = true;
  };
}
