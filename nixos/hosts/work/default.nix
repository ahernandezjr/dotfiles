{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "work";

  users.users.alex.extraGroups = [ "gamemode" ];

  systemSettings = {
    # Docker is explicitly omitted or disabled to fulfill "no docker containers"
    docker.enable = false;

    development.postgresql.enable = true;
    niri.enable = true;
    nvidia.enable = true;
    gaming = {
      enable = true;
      sunshine.enable = true;
    };
    vfio.enable = true; 
    cachyos-kernel.enable = true;
    browsers.brave.enable = true;
    virtualization = {
      enable = true;
      waydroid.enable = true;
    };
    drivers = {
      peripherals.enable = true;
      lenovo-legion.enable = true;
    };
  };

  # Prevent lid close from suspending and fix Nvidia Wayland suspend issues
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  environment.variables = {
    SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  };
}
