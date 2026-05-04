{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "work";

  users.users.alex.extraGroups = [ "gamemode" ];

  systemSettings = {
    # Docker is explicitly omitted or disabled to fulfill "no docker containers"
    docker.enable = false;

    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
    vfio.enable = false; # Disabled for work laptop unless needed
    cachyos-kernel.enable = true;
    browsers.brave.enable = true;
    virtualization.enable = true;
    drivers = {
      peripherals.enable = true;
      lenovo-legion.enable = true;
    };
  };
}
