{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.systemSettings.vfio;
in
{
  options.systemSettings.vfio = {
    enable = mkEnableOption "Single GPU Passthrough (RisingPrism)";
    
    gpuIds = mkOption {
      type = types.listOf types.str;
      default = [ "10de:2b85" "10de:22e8" ]; # Default for RTX 5090
      description = "PCI IDs of the GPU and its audio device. Use 'lspci -nn | grep -i nvidia' to find yours.";
    };

    pciBusIds = mkOption {
      type = types.listOf types.str;
      default = [ "0000:01:00.0" "0000:01:00.1" ];
      description = "PCI Bus IDs of the GPU and its audio device. Use 'lspci -D' to find yours.";
    };

    vmName = mkOption {
      type = types.str;
      default = "win11";
      description = "Name of the VM to trigger the passthrough for";
    };
  };

  config = mkIf cfg.enable {
    # Virtualization configuration
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    # Kernel Parameters for IOMMU and VFIO
    boot.kernelParams = 
      (if (lib.elem "kvm-intel" config.boot.kernelModules) then [ "intel_iommu=on" ]
       else if (lib.elem "kvm-amd" config.boot.kernelModules) then [ "amd_iommu=on" ]
       else [ ])
      ++ [ "iommu=pt" "kvm.ignore_msrs=1" "video=efifb:off" ];

    # Required modules for VFIO
    boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];

    # RisingPrism Libvirt Hooks implementation
    virtualisation.libvirtd.hooks.qemu = {
      risingprism = pkgs.writeShellScript "vfio-hook" ''
        # Paths for NixOS binaries
        export PATH="$PATH:${pkgs.libvirt}/bin:${pkgs.systemd}/bin:${pkgs.kmod}/bin:${pkgs.procps}/bin:${pkgs.psmisc}/bin"
        
        GUEST_NAME="$1"
        OPERATION="$2"
        SUB_OPERATION="$3"

        # Only execute if the guest name matches our configured VM
        if [[ "$GUEST_NAME" != "${cfg.vmName}" ]]; then
            exit 0
        fi

        if [[ "$OPERATION" == "prepare" && "$SUB_OPERATION" == "begin" ]]; then
            # 1. Stop Display Manager
            systemctl stop display-manager.service
            
            # 2. Unbind VTconsoles
            if [ -f /sys/class/vtconsole/vtcon0/bind ]; then echo 0 > /sys/class/vtconsole/vtcon0/bind; fi
            if [ -f /sys/class/vtconsole/vtcon1/bind ]; then echo 0 > /sys/class/vtconsole/vtcon1/bind; fi
            
            # 3. Unbind EFI-Framebuffer
            if [ -d "/sys/bus/platform/drivers/efi-framebuffer" ]; then
                echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
            fi
            
            # 4. Kill processes using the GPU
            fuser -k /dev/nvidia*
            
            # 5. Small sleep to avoid race conditions
            sleep 2
            
            # 6. Unload GPU drivers
            modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
            
            # 7. Detach GPU from host
            ${concatMapStringsSep "\n" (id: "virsh nodedev-detach pci_${replaceStrings ["." ":" "-"] ["_" "_" "_"] id}") cfg.pciBusIds}
            
            # 8. Load VFIO
            modprobe vfio-pci
            
        elif [[ "$OPERATION" == "release" && "$SUB_OPERATION" == "end" ]]; then
            # 1. Reattach GPU to host
            ${concatMapStringsSep "\n" (id: "virsh nodedev-reattach pci_${replaceStrings ["." ":" "-"] ["_" "_" "_"] id}") cfg.pciBusIds}
            
            # 2. Unload VFIO
            modprobe -r vfio-pci
            
            # 3. Reload GPU drivers
            modprobe nvidia nvidia_uvm nvidia_modeset nvidia_drm
            
            # 4. Rebind VTconsoles
            if [ -f /sys/class/vtconsole/vtcon0/bind ]; then echo 1 > /sys/class/vtconsole/vtcon0/bind; fi
            if [ -f /sys/class/vtconsole/vtcon1/bind ]; then echo 1 > /sys/class/vtconsole/vtcon1/bind; fi
            
            # 5. Restart Display Manager
            systemctl start display-manager.service
        fi
      '';
    };

    # Add user to necessary groups
    users.users.alex.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];

    # Essential packages for management and debugging
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      pciutils
      bridge-utils
      psmisc
      (writeShellScriptBin "start-gaming-vm" ''
        virsh --connect qemu:///system start ${cfg.vmName}
        virt-viewer --connect qemu:///system --wait ${cfg.vmName}
      '')
    ];

    # Persistence for libvirt (optional but recommended for state)
    # environment.etc."libvirt/qemu/networks/autostart/default.xml".source = "${pkgs.libvirt}/etc/libvirt/qemu/networks/default.xml";
  };
}
