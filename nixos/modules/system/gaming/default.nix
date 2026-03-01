{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.gaming;
in
{
  options.systemSettings.gaming = {
    enable = lib.mkEnableOption "system-level gaming optimizations";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false; # Set to false to fix 'Operation not permitted' crash
    };

    environment.sessionVariables = {
      # Steam/Gamescope Wayland Integration
      ENABLE_GAMESCOPE_WSI = "1";
      # Leverage GSP firmware specifically within Gamescope
      GS_USE_GSP = "1";
      # Ensure Gamescope/XWayland uses the NVIDIA dGPU
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
      # Force HDR off everywhere to prevent NVIDIA flickering
      DXVK_HDR = "0";
      ENABLE_GAMESCOPE_HDR = "0";
      WLR_DRM_NO_HDR = "1";
      # Fix DX12 flickering by disabling present_wait
      VKD3D_DISABLE_EXTENSIONS = "VK_KHR_present_wait";
    };
  };
}
