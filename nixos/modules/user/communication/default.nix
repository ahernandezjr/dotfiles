{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.userSettings.communication;
in
{
  options.userSettings.communication = {
    enable = lib.mkEnableOption "Communication apps like Vesktop (Discord alternative)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}
