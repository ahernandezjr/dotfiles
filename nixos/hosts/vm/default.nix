{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings = {
    docker.enable = true;
    development.postgresql.enable = true;
    niri.enable = true;
  };
}
