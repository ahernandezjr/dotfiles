# Docker Compose stacks as user systemd services (start on session start).
# docker = { enable = true; containers = { defaults = { ... }; qbittorentvpn = { enable = true; }; }; }
{ config, lib, pkgs, repoPath ? "/home/alex/dotfiles", ... }:

let
  cfg = config.userSettings.docker;
  containerCfg = cfg.containers;
  defaults = containerCfg.defaults or { };
  startOnSession = defaults.startOnSession or true;
  # Per-container: all keys except "defaults", where enable = true
  enabledContainers = lib.filterAttrs (name: c: name != "defaults" && (c.enable or false)) containerCfg;
in
{
  options.userSettings.docker = {
    enable = lib.mkEnableOption "Docker compose stacks (user systemd)";
    containers = lib.mkOption {
      type = lib.types.submodule {
        options.defaults = lib.mkOption {
          type = lib.types.submodule {
            options.startOnSession = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Start enabled containers on session start (default for all).";
            };
          };
          default = { };
          description = "Options applied to all containers.";
        };
        freeformType = lib.types.attrsOf (lib.types.submodule {
          options.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Start this compose project on session start";
          };
        });
      };
      default = { };
      description = "defaults = options for all; other keys = per-container (subdir under docker/).";
    };
  };

  config = lib.mkIf (cfg.enable && startOnSession) {
    systemd.user.services = lib.mapAttrs' (name: _: lib.nameValuePair "docker-compose-${name}" {
      Unit.Description = "Docker Compose: ${name}";
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "${repoPath}/docker/${name}";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      };
    }) enabledContainers;

    # Start enabled containers on activation (so they run after home-manager switch, not only after login).
    home.activation.startDockerContainers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${lib.concatMapStrings (name: "systemctl --user start docker-compose-${name} 2>/dev/null || true\n") (lib.attrNames enabledContainers)}
    '';
  };
}
