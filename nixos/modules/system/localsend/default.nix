# LocalSend: cross-platform file transfer. Enabled on every host.
{ config, pkgs, ... }:

{
  config = {
    programs.localsend.enable = true;
    programs.localsend.openFirewall = true;
  };
}
