{ pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];

  # Add essential kernel modules for laptop hardware to prevent kernel panic.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
}
