{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings = {
    development.docker.enable = true;
    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
  };
}
