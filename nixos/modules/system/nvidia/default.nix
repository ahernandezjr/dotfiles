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
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    boot.kernelParams = [
      # Fix sleep issues with deep sleep
      "mem_sleep_default=s2idle"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
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
      powerManagement = {
        enable = true;
        finegrained = false;
      };

      # Use the NVidia open source kernel module.
      open = true;

      # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Use the production Nvidia branch from nixpkgs
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        # version = "590.48.01";
        # sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
        # sha256_aarch64 = "sha256-FOz7f6pW1NGM2f74kbP6LbNijxKj5ZtZ08bm0aC+/YA=";
        # openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
        # settingsSha256 = "sha256-NWsqUciPa4f1ZX6f0By3yScz3pqKJV1ei9GvOF8qIEE=";
        # persistencedSha256 = "sha256-wsNeuw7IaY6Qc/i/AzT/4N82lPjkwfrhxidKWUtcwW8=";
      # };
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
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };
}
