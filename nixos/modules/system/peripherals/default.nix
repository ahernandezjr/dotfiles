{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.peripherals;
in
{
  options.systemSettings.peripherals = {
    enable = lib.mkEnableOption "system-level peripheral drivers";
  };

  config = lib.mkIf cfg.enable {
    hardware.openrazer.enable = true;

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];

    users.users.alex = { extraGroups = [ "openrazer" ]; };
  };
}
