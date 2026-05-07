{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.virtualization;

  # XML configuration for the default network
  defaultNetworkXml = pkgs.writeText "default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';

  # Service script to initialize libvirt resources
  libvirtInit = pkgs.writeShellApplication {
    name = "libvirt-init";
    runtimeInputs = with pkgs; [ libvirt gnugrep gawk xmlstarlet ];
    text = ''
      # 1. Define Default Network
      if ! virsh net-info default >/dev/null 2>&1; then
        virsh net-define "${defaultNetworkXml}"
      fi
      
      if [ "$(virsh net-info default | grep 'Active' | awk '{print $2}')" = "no" ]; then
        virsh net-start default
      fi
      virsh net-autostart default

      # 2. Define Default Storage Pool
      if ! virsh pool-info default >/dev/null 2>&1; then
        virsh pool-define-as default dir --target /var/lib/libvirt/images
      fi
      
      if [ "$(virsh pool-info default | grep 'Active' | awk '{print $2}')" = "no" ]; then
        virsh pool-start default
      fi
      virsh pool-autostart default

      # 3. Declarative VM Hardware Tweaks (Multi-Monitor/RAM)
      vm_name=$(virsh list --all --name | head -n 1)
      if [ -n "$vm_name" ]; then
        current_xml=$(virsh dumpxml "$vm_name")
        modified=false

        # Ensure 2 display heads
        heads=$(echo "$current_xml" | xmlstarlet sel -t -v "//video/model/@heads" || echo "1")
        if [ "$heads" = "1" ]; then
          echo "Updating $vm_name to 2 display heads..."
          current_xml=$(echo "$current_xml" | xmlstarlet ed -u "//video/model/@heads" -v 2)
          modified=true
        fi

        # Ensure 16GB RAM (16777216 KiB)
        current_mem=$(echo "$current_xml" | xmlstarlet sel -t -v "//memory" || echo "0")
        if [ "$current_mem" != "16777216" ]; then
          echo "Updating $vm_name RAM to 16GB..."
          current_xml=$(echo "$current_xml" | xmlstarlet ed -u "//memory" -v 16777216 \
                                             -u "//currentMemory" -v 16777216)
          modified=true
        fi

        if [ "$modified" = true ]; then
          echo "$current_xml" | virsh define /dev/stdin
        fi
      fi
    '';
  };

  # User script to connect to the Windows VM
  winConnect = pkgs.writeShellApplication {
    name = "win-connect";
    runtimeInputs = with pkgs; [ libvirt virt-viewer dconf ];
    text = ''
      vm_name=$(virsh --connect qemu:///system list --all --name | head -n 1)
      
      if [ -z "$vm_name" ]; then
        echo "Error: No virtual machines found."
        exit 1
      fi

      if [ "$(virsh --connect qemu:///system domstate "$vm_name")" != "running" ]; then
        echo "Starting $vm_name..."
        virsh --connect qemu:///system start "$vm_name"
      fi

      # Collect arguments
      viewer_args=()
      # Add hotkey to release cursor (Shift+Escape) to avoid conflict with Niri's Super+Escape
      viewer_args+=("--hotkeys=release-cursor=shift+Escape")

      for arg in "$@"; do
        case $arg in
          -f|--fullscreen) viewer_args+=("-f") ;;
        esac
      done

      echo "Connecting to $vm_name via SPICE..."
      # Use ''${viewer_args[@]} to escape the bash array for Nix
      virt-viewer -c qemu:///system --wait "''${viewer_args[@]}" "$vm_name" &
    '';
  };

in
{
  options.systemSettings.virtualization.enable = lib.mkEnableOption "Enable QEMU/KVM virtualization";

  config = lib.mkIf cfg.enable {
    # --- Virtualization Backend ---
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };

    # --- System Configuration ---
    boot.kernelModules = [ "kvm-intel" "vfio" "vfio_pci" "virtiofs" ];
    programs.dconf.enable = true;

    # Set default URI for virsh/virt-manager
    environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

    # --- Initialization Service ---
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

    # --- Packages & User Tools ---
    environment.systemPackages = with pkgs; [
      # Management Tools
      virt-manager
      virt-viewer
      virtiofsd
      libguestfs
      
      # Networking & Utilities
      cifs-utils
      spice-vdagent
      bridge-utils
      
      # Custom Scripts
      winConnect
    ];

    # Add user to required groups
    users.users.alex.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
  };
}
