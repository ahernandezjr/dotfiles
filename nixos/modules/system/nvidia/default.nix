{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.nvidia;
in
{
  options.systemSettings.nvidia = {
    enable = lib.mkEnableOption "NVIDIA drivers";
  };

  config = lib.mkIf cfg.enable {
    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Modesetting is required for Wayland.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module.
      open = true;

      # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Select the appropriate driver version for your specific GPU.
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
    };
  };
}
