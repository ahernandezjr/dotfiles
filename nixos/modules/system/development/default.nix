# Development options (postgresql). Config in postgresql.nix.
{ config, lib, ... }:

{
  options.systemSettings.development = {
    postgresql = {
      enable = lib.mkEnableOption "PostgreSQL database";
    };
  };
}
