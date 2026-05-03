{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.virtualization;
in
{
  options.systemSettings.virtualization = {
    enable = lib.mkEnableOption "Enable QEMU/KVM virtualization with libvirtd";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    # Required for VirtIO-FS and high-performance VM networking/storage
    boot.kernelModules = [ "kvm-intel" "vfio" "vfio_pci" "virtiofs" ];

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice-vdagent
      bridge-utils
      libguestfs # Useful for mounting VM disks
    ];

    # Add user to libvirtd group for management without sudo
    users.users.alex.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
  };
}
