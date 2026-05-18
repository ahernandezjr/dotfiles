# Sunshine: self-hosted game stream host for Moonlight.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.systemSettings.gaming.sunshine;
in
{
  options.systemSettings.gaming.sunshine = {
    enable = lib.mkEnableOption "Sunshine game streaming server";
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start Sunshine automatically on login";
    };
  };

  config = lib.mkIf cfg.enable {
    # Sunshine requires these ports to be open
    networking.firewall = {
      allowedTCPPorts = [ 47984 47989 47990 48010 ];
      allowedUDPPortRanges = [
        { from = 47998; to = 48000; }
        { from = 48002; to = 48010; }
      ];
    };

    services.sunshine = {
      enable = true;
      autoStart = cfg.autoStart;
      capSysAdmin = true; # Needed for KMS capture
      openFirewall = false; # We handle it manually above for clarity
    };

    # Uinput rules for controller support
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
    '';

    # Ensure avahi is running for discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
  };
}
