{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.obsidian;
in
{
  options.systemSettings.obsidian = {
    enable = lib.mkEnableOption "Obsidian Remote web container";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to expose the Obsidian web interface on.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix secret containing VNC password (e.g. PASSWORD=...)";
    };
    vaultPath = lib.mkOption {
      type = lib.types.str;
      default = "/home/alex/Shared/ObsidianVault";
      description = "Path to the local Obsidian vault folder on the system.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemSettings.docker.enable = true;

    virtualisation.oci-containers = {
      backend = "docker";
      containers.obsidian = {
        image = "lscr.io/linuxserver/obsidian:latest";
        ports = [ "${toString cfg.port}:8080" ];
        environment = {
          PUID = "1000"; # alex
          PGID = "100";  # users
          TZ = "America/Chicago";
        };
        environmentFiles = [ cfg.passwordFile ];
        volumes = [
          "/home/alex/.config/obsidian-remote:/config"
          "${cfg.vaultPath}:/config/Obsidian/Vault"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
