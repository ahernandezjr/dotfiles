# Docker daemon + docker-compose stacks (systemd). Enable per-host via systemSettings.docker.enable.
{ config, lib, pkgs, repoPath ? "/home/alex/dotfiles", ... }:

let
  cfg = config.systemSettings.docker;
  containersCfg = cfg.containers;
  defaults = containersCfg.defaults or { };

  defaultUser = defaults.user or "alex";
  defaultHome = defaults.home or "/home/${defaultUser}";
  startOnBootDefault = defaults.startOnBoot or true;
  applyOnSwitchDefault = defaults.applyOnSwitch or true;

  allContainers =
    lib.filterAttrs (name: _: name != "defaults") containersCfg;
  enabledContainers =
    lib.filterAttrs (name: c: name != "defaults" && (c.enable or false)) containersCfg;
in
{
  options.systemSettings.docker = {
    enable = lib.mkEnableOption "Docker daemon and docker compose stacks";

    containers = lib.mkOption {
      type = lib.types.submodule {
        options.defaults = lib.mkOption {
          type = lib.types.submodule {
            options = {
              user = lib.mkOption {
                type = lib.types.str;
                default = "alex";
                description = "User to run docker-compose as.";
              };
              home = lib.mkOption {
                type = lib.types.str;
                default = "/home/${config.systemSettings.docker.containers.defaults.user}";
                description = "HOME for docker-compose env expansion.";
              };
              startOnBoot = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Start enabled containers on boot.";
              };
              applyOnSwitch = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Restart enabled containers on nixos-rebuild switch.";
              };
            };
          };
          default = { };
          description = "Options applied to all containers.";
        };
        freeformType = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable this docker-compose project.";
            };
            startOnBoot = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Override defaults.startOnBoot for this container.";
            };
            applyOnSwitch = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Override defaults.applyOnSwitch for this container.";
            };
          };
        });
      };
      default = { };
      description = "defaults = shared options; other keys = compose project under docker/<name>/.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      virtualisation.docker = {
        enable = true;
        storageDriver = "overlay2"; # "btrfs";
        enableOnBoot = true;
        daemon.settings.data-root = "/mnt/linuxgames/docker";
      };

      users.users.${defaultUser}.extraGroups = [ "docker" ];
      environment.systemPackages = with pkgs; [ docker-compose ];
    }

    # NVIDIA GPU in containers. Enable CDI so compose can use `driver: cdi`.
    (lib.mkIf (config.systemSettings.nvidia.enable or false) {
      hardware.nvidia-container-toolkit.enable = true;
      virtualisation.docker.daemon.settings.features.cdi = true;
    })

    # One systemd service per enabled container (runs as user, but starts at boot).
    {
      systemd.services = lib.mapAttrs' (name: c:
        let
          startOnBoot = if c.startOnBoot == null then startOnBootDefault else c.startOnBoot;
          isDndKit = name == "dnd-kit";
        in
        lib.nameValuePair "docker-compose-${name}" ({
          description = "Docker Compose: ${name}";
          after = [ "docker.service" "network-online.target" ];
          wants = [ "network-online.target" ];
          requires = [ "docker.service" ];
          path = [ pkgs.docker-compose ] ++ lib.optionals isDndKit [ pkgs.docker ];
          preStart = lib.optionalString isDndKit ''
            ${pkgs.docker}/bin/docker network create hai-network 2>/dev/null || true
            mkdir -p ${defaultHome}/.dnd-kit/foundry/data
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = defaultUser;
            Group = "docker";
            WorkingDirectory = "${repoPath}/docker/${name}";
            Environment = [
              "HOME=${defaultHome}"
              "USER=${defaultUser}"
            ];
            ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
            ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
            TimeoutStartSec = "10min";
          };
          restartIfChanged = true;
        } // lib.optionalAttrs startOnBoot {
          wantedBy = [ "multi-user.target" ];
        })
      ) enabledContainers;
    }

    # Apply changes on switch *after* /etc updates (so unit files exist).
    # Non-blocking so a big image pull doesn't hang `nixos-rebuild switch`.
    {
      system.activationScripts.dockerComposeApplyOnSwitch =
        lib.mkIf applyOnSwitchDefault (lib.stringAfter [ "etc" ] ''
          ${pkgs.systemd}/bin/systemctl daemon-reload 2>/dev/null || true

          ${lib.concatMapStrings (name:
            let
              c = allContainers.${name};
              enabled = c.enable or false;
              applyOnSwitch = if c.applyOnSwitch == null then applyOnSwitchDefault else c.applyOnSwitch;
            in
            if enabled && applyOnSwitch then
              "${pkgs.systemd}/bin/systemctl restart --no-block docker-compose-${name}.service 2>/dev/null || true\n"
            else if (!enabled) then
              "${pkgs.systemd}/bin/systemctl stop --no-block docker-compose-${name}.service 2>/dev/null || true\n"
            else
              ""
          ) (lib.attrNames allContainers)}
        '');
    }
  ]);
}
