{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  users.users.alex.extraGroups = [ "gamemode" ];

  systemSettings = {
    docker = {
      enable = true;
      containers = {
        qbittorentvpn.enable = true;
        localai.enable = false;
      };
    };
    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
  };
}
