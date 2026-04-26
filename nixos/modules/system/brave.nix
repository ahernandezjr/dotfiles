# System-level Brave configuration bridge.
# Bridges user-defined policies from Home Manager to /etc/brave/policies.
# Source: https://gist.github.com/hoyhoy/1c675f6f02118f6e0db7616c070917ac

{ config, lib, ... }:

let
  cfg = config.systemSettings.browsers.brave;
  
  # Access the policies defined in the user's home-manager config
  # We use the primary user 'alex' as defined in your flake
  userBravePolicies = config.home-manager.users.alex.userSettings.browsers.brave.policies or {};
  braveEnabled = config.home-manager.users.alex.userSettings.browsers.brave.enable or false;
in
{
  options.systemSettings.browsers.brave = {
    enable = lib.mkEnableOption "Enable system-level Brave hardening bridge";
  };

  config = lib.mkIf cfg.enable {
    # System-level telemetry blocking via hosts
    networking.hosts."0.0.0.0" = [
      "p3a.brave.com"
      "rewards.brave.com"
      "api.rewards.brave.com"
      "grant.rewards.brave.com"
      "variations.brave.com"
      "laptop-updates.brave.com"
      "static1.brave.com"
      "crlsets.brave.com"
      "static.brave.com"
      "ads.brave.com"
      "ads-admin.brave.com"
      "ads-help.brave.com"
      "referrals.brave.com"
      "analytics.brave.com"
      "search.anonymous.ads.brave.com"
      "star-randsrv.bsg.brave.com"
      "usage-ping.brave.com"
      "sync-v2.brave.com"
      "redirector.brave.com"
    ];

    # Apply the user-defined policies to Brave's system paths
    environment.etc."brave/policies/managed/policy.json".text = builtins.toJSON userBravePolicies;
    environment.etc."brave-browser/policies/managed/policy.json".text = builtins.toJSON userBravePolicies;
  };
}
