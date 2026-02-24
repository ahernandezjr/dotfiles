# Development options (docker, postgresql). Config in docker.nix and postgresql.nix.
{ config, lib, ... }:

{
  options.systemSettings.development = {
    docker = {
      enable = lib.mkEnableOption "Docker and docker compose";
    };
    postgresql = {
      enable = lib.mkEnableOption "PostgreSQL database";
    };
  };
}
