{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "vm";

  systemSettings = {
    docker.enable = true;
    development.postgresql.enable = true;
    niri.enable = true;
  };
}
