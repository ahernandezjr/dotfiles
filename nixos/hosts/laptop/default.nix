{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings = {
    docker.enable = true;
    development.postgresql.enable = true;
    niri.enable = true;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
}
