# PostgreSQL. Enable per-host via systemSettings.development.postgresql.enable.
{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.development.postgresql;
in
{
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
    };
  };
}
