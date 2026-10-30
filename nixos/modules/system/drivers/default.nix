{
  config,
  lib,
  pkgs,
  ...
}:

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
      hardware.openrazer = {
        enable = true;
        batteryNotifier.enable = false;
      };

      services.input-remapper.enable = true;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "inputremapper" && subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';

      hardware.logitech.wireless.enable = true;
      programs.solaar.enable = true;

      environment.systemPackages = with pkgs; [
        openrazer-daemon
        polychromatic
      ];

      programs.gpu-screen-recorder = {
        enable = true;
        ui.enable = true; # overlay
      };

      users.users.alex = {
        extraGroups = [
          "openrazer"
          "input"
        ];
      };
    })

    (lib.mkIf cfg.lenovo-legion.enable {
      boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
      environment.systemPackages = [ pkgs.lenovo-legion ];
    })
  ];
}
