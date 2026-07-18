# Data Sharing (Syncthing): continuous file synchronization. Enabled on every host.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # LocalSend: cross-platform file transfer
  programs.localsend.enable = !config.systemSettings.minimal.enable;
  programs.localsend.openFirewall = !config.systemSettings.minimal.enable;

  # Syncthing: continuous file synchronization
  services.syncthing = {
    enable = true;
    user = "alex";
    dataDir = "/home/alex";
    configDir = "/home/alex/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    
    # Official way to handle GUI password without the Nix store
    guiPasswordFile = config.age.secrets.syncthing-password.path;
    
    settings = {
      gui = {
        user = "alex"; # The user is less sensitive, but we can manage it here
      };
      devices = {
        "desktop" = {
          # Device 1
          id = "XIXQ3S6-7CO6V3C-3ZKVXRD-Y2DJIOI-DEB5OJR-UH6BZYP-3OPTN2U-HCSXHQT";
        };
        "laptop" = {
          # Device 2 (former work laptop)
          id = "B6SBSS4-M256RJE-WLXCBO2-NCEWR7G-SG6S3EA-PPTD2ME-ILHH432-3JYBWAB";
        };
      };
      folders = {
        "Shared" = {
          path = "/home/alex/Shared";
          devices = [
            "desktop"
            "laptop"
          ];
        };
        "Ryujinx-Config" = {
          path = "/home/alex/.config/Ryujinx";
          devices = [
            "desktop"
            "laptop"
          ];
        };
        "Nix-Private-Pkgs" = {
          path = "/home/alex/dotfiles/nixos/pkgs-private";
          devices = [
            "desktop"
            "laptop"
          ];
        };
      };
    };
  };

  # Identity paths for Agenix
  age.identityPaths = [ 
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/alex/.ssh/id_ed25519" 
  ];

  # Agenix secrets for Syncthing GUI credentials
  age.secrets.syncthing-password = {
    file = ../../../secrets/syncthing-password.age;
    owner = "alex";
  };
  age.secrets.syncthing-user = {
    file = ../../../secrets/syncthing-user.age;
    owner = "alex";
  };

  # Delay Syncthing startup until the home directory partition is fully mounted.
  # This prevents a race condition on boot where Syncthing starts too early,
  # finds a blank /home/alex/ path on the root partition, and regenerates new keys.
  systemd.services.syncthing = {
    after = [ "home.mount" ];
    requires = [ "home.mount" ];
  };
}
