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

      systemd.services.waydroid-container = {
        preStart = ''
          ${pkgs.python3}/bin/python3 -c '
          import configparser, os, glob, re
          cfg_path = "/var/lib/waydroid/waydroid.cfg"
          if not os.path.exists(cfg_path): exit(0)

          # 1. Detect GPU
          gpu_node = None
          for path in glob.glob("/sys/class/drm/renderD*"):
              vendor_path = os.path.join(path, "device/vendor")
              if os.path.exists(vendor_path):
                  with open(vendor_path, "r") as f:
                      vendor = f.read().strip()
                  if vendor in ("0x1002", "0x8086"):
                      gpu_node = f"/dev/dri/{os.path.basename(path)}"
                      break

          # 2. Patch waydroid.cfg
          config = configparser.ConfigParser(interpolation=None)
          config.optionxform = str
          config.read(cfg_path)
          if "waydroid" not in config: config["waydroid"] = {}
          if "properties" not in config: config["properties"] = {}

          if gpu_node:
              print(f"Waydroid setup: Found AMD/Intel GPU at {gpu_node}")
              config["waydroid"]["drm_device"] = gpu_node
              config["properties"].pop("ro.hardware.gralloc", None)
              config["properties"].pop("ro.hardware.egl", None)
          else:
              print("Waydroid setup: No AMD/Intel GPU found. Configuring software rendering (SwiftShader)")
              config["waydroid"].pop("drm_device", None)
              config["properties"]["ro.hardware.gralloc"] = "default"
              config["properties"]["ro.hardware.egl"] = "swiftshader"
          with open(cfg_path, "w") as f:
              config.write(f)

          # 3. Patch property and lxc config files directly
          use_swift = (gpu_node is None)
          
          def patch_prop_file(prop_path, target_node, use_swiftshader):
              if not os.path.exists(prop_path): return
              with open(prop_path, "r") as f:
                  lines = f.readlines()
              new_lines = []
              has_gralloc = False
              has_egl = False
              for line in lines:
                  if line.startswith("gralloc.gbm.device="):
                      if use_swiftshader: continue
                      else: line = f"gralloc.gbm.device={target_node}\n"
                  elif line.startswith("ro.hardware.gralloc="):
                      has_gralloc = True
                      if use_swiftshader: line = "ro.hardware.gralloc=default\n"
                      else: line = "ro.hardware.gralloc=gbm\n"
                  elif line.startswith("ro.hardware.egl="):
                      has_egl = True
                      if use_swiftshader: line = "ro.hardware.egl=swiftshader\n"
                      else: line = "ro.hardware.egl=mesa\n"
                  new_lines.append(line)
              if use_swiftshader:
                  if not has_gralloc: new_lines.append("ro.hardware.gralloc=default\n")
                  if not has_egl: new_lines.append("ro.hardware.egl=swiftshader\n")
              with open(prop_path, "w") as f:
                  f.writelines(new_lines)

          def patch_lxc_nodes(nodes_path, target_node):
              if not os.path.exists(nodes_path): return
              with open(nodes_path, "r") as f:
                  content = f.read()
              new_content = re.sub(
                  r"lxc\.mount\.entry\s*=\s*/dev/dri/renderD\d+\s+dev/dri/renderD\d+",
                  f"lxc.mount.entry = {target_node} dev/dri/{os.path.basename(target_node)}",
                  content
              )
              with open(nodes_path, "w") as f:
                  f.write(new_content)

          patch_prop_file("/var/lib/waydroid/waydroid.prop", gpu_node, use_swift)
          patch_prop_file("/var/lib/waydroid/waydroid_base.prop", gpu_node, use_swift)
          if gpu_node:
              patch_lxc_nodes("/var/lib/waydroid/lxc/waydroid/config_nodes", gpu_node)
          '
        '';
      };
    })
  ];
}
