{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.nvidia;
in
{
  options.systemSettings.nvidia = {
    enable = lib.mkEnableOption "NVIDIA drivers";
  };

  config = lib.mkIf cfg.enable {
    # Blackwell (RTX 50-series) requires the most recent hardware support available.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    boot.kernelParams = [
      # PAT: Improves memory mapping efficiency between CPU and GPU, reducing stutter.
      "nvidia.NVreg_UsePageAttributeTable=1"
      # GSP: Mandatory for Blackwell (50-series) stability; offloads initialization to GPU firmware.
      "nvidia.NVreg_UseGSPRM=1"
      # RMIntr: The "flicker fix" for Wayland; prioritizes display interrupts during GPU contention.
      "nvidia.NVreg_RegistryDwords=RMIntrLockingMode=1"
      # fbdev: Ensures smooth boot transitions and proper TTY support on NVIDIA.
      "nvidia_drm.fbdev=1"
    ];

    hardware.nvidia = {
      # Modesetting is required for Wayland.
      modesetting.enable = true;
      
      # Enable to avoid niri blackscreen on reboot
      powerManagement.enable = true;

      # Use the NVidia open source kernel module.
      open = true;

      # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Use the stable Nvidia branch from nixpkgs.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Add environment variables for Wayland sessions
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
        vulkan-loader
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        nvidia-vaapi-driver
        libvdpau-va-gl
        vulkan-loader
      ];
    };
  };
}
