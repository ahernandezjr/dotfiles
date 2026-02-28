{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings = {
    docker = {
      enable = true;
      containers = {
        qbittorentvpn.enable = true;
        localai.enable = true;
      };
    };
    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
  };
}
