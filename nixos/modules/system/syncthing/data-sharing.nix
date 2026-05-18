# Data Sharing (Syncthing): continuous file synchronization. Enabled on every host.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # LocalSend: cross-platform file transfer
  programs.localsend.enable = true;
  programs.localsend.openFirewall = true;

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
          id = "GGIL74E-CAJM5ET-G3JSLBP-P2IIP7M-WEFVXTQ-ZXM522W-N2FA4BR-YAZXHAB";
        };
        "work" = {
          # Device 2
          id = "REPLACE-WITH-WORK-ID";
        };
        "laptop" = {
          id = "REPLACE-WITH-LAPTOP-ID";
        };
        "vm" = {
          id = "REPLACE-WITH-VM-ID";
        };
      };
      folders = {
        "Shared" = {
          path = "/home/alex/Shared";
          devices = [
            "desktop"
            "work"
            "laptop"
            "vm"
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
}
