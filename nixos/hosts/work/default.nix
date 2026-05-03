{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  users.users.alex.extraGroups = [ "gamemode" ];

  systemSettings = {
    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
    vfio.enable = true;
    cachyos-kernel.enable = true;
    browsers.brave.enable = true;
    peripherals.enable = true;
  };
}
