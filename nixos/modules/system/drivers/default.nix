{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.drivers;
in
{
  options.systemSettings.drivers = {
    peripherals.enable = lib.mkEnableOption "system-level peripheral drivers (Razer, etc.)";
    lenovo-legion.enable = lib.mkEnableOption "Lenovo Legion specific drivers and utilities";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.peripherals.enable {
      hardware.openrazer.enable = true;

      environment.systemPackages = with pkgs; [
        openrazer-daemon
        polychromatic
      ];

      users.users.alex = { extraGroups = [ "openrazer" ]; };
    })

    (lib.mkIf cfg.lenovo-legion.enable {
      boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
      environment.systemPackages = [ pkgs.lenovo-legion ];
    })
  ];
}
