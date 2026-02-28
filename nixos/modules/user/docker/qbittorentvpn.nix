# qbittorent + gluetun VPN stack. Enable via userSettings.docker.containers.qbittorentvpn.enable.
{ config, lib, ... }:

{
  config.userSettings.docker.containers.qbittorentvpn.enable = lib.mkDefault true;
}
