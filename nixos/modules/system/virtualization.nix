{ config, lib, pkgs, ... }:
let
  cfg = config.systemSettings.virtualization;
  libvirtInit = pkgs.writeShellScriptBin "libvirt-init" ''
    # Add libvirt resource setup logic here
  '';
in
{
  options.systemSettings.virtualization = {
    enable = lib.mkEnableOption "Enable QEMU/KVM virtualization";
    waydroid.enable = lib.mkEnableOption "Enable Waydroid Android emulation";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.libvirtd = {
        enable = true;
        onBoot = lib.mkDefault "start";
        onShutdown = lib.mkDefault "shutdown";
        qemu = {
          package = lib.mkDefault pkgs.qemu_kvm;
          runAsRoot = lib.mkDefault true;
          swtpm.enable = lib.mkDefault true;
          vhostUserPackages = [ pkgs.virtiofsd ];
        };
      };
      boot.kernelModules = [ "kvm-intel" "vfio" "vfio_pci" "virtiofs" ];
      programs.dconf.enable = true;
      environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";
      systemd.services.libvirt-init = {
        description = "Declarative setup for libvirt resources";
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${libvirtInit}/bin/libvirt-init";
        };
      };
      environment.systemPackages = with pkgs; [
        virt-manager virt-viewer virtiofsd libguestfs
        cifs-utils spice-vdagent bridge-utils
      ];
      users.users.alex.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
    })
    (lib.mkIf cfg.waydroid.enable {
      virtualisation.waydroid.enable = true;
      networking.firewall.trustedInterfaces = [ "waydroid0" ];
    })
  ];
}
