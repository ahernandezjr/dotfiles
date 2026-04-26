{ config, lib, pkgs, ... }:

let
  cfg = config.systemSettings.cachyos-kernel;
in
{
  options.systemSettings.cachyos-kernel = {
    enable = lib.mkEnableOption "CachyOS kernel";
  };

  config = lib.mkIf cfg.enable {
    # Use the CachyOS latest kernel packages provided by the overlay.
    # This should match the cached binaries in the Lantian/Garnix caches.
    boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };
}
