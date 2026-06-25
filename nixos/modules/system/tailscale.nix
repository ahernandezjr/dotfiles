{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.tailscale;
in
{
  options.systemSettings.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN service";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    
    # Allow Tailscale exit node & subnet routing traffic
    networking.firewall.checkReversePath = "loose";
  };
}
