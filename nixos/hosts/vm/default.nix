{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings.niri.enable = true;
}
