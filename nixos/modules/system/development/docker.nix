# Docker and docker compose. Enable per-host via systemSettings.development.docker.enable.
{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.development.docker;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };

    users.users.alex.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
