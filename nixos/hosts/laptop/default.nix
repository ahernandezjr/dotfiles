{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  systemSettings.niri.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
}
