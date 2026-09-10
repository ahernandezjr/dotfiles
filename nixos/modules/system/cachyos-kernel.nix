{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.systemSettings.cachyos-kernel;
in
{
  options.systemSettings.cachyos-kernel = {
    enable = lib.mkEnableOption "CachyOS kernel and system-level gaming optimizations";
    ananicy = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ananicy-cpp process priority daemon with CachyOS rules";
    };
    scx = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sched-ext scheduler (scx_bpfland)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use the CachyOS latest kernel packages provided by the overlay.
    boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;

    # CachyOS kernel sysctl performance tuning suite
    boot.kernel.sysctl = {
      # Memory map limit for massive modpacks (Skyrim, Fallout, Starfield, Cyberpunk)
      "vm.max_map_count" = 2147483642;

      # Max open file descriptors limit for loose-file modding
      "fs.file-max" = 2097152;

      # Disable split-lock mitigation penalty (prevents micro-stutter in games/Wine)
      "kernel.split_lock_mitigate" = 0;

      # VFS cache pressure tuning (keeps filesystem dentries/inodes in RAM for fast MO2 indexing)
      "vm.vfs_cache_pressure" = 50;

      # Dirty memory writeback optimization for high-throughput gaming I/O
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;

      # Prevent proactive memory compaction spikes while gaming
      "vm.compaction_proactiveness" = 0;
      "vm.watermark_boost_factor" = 1;
    };

    # Kernel boot parameters for transparent huge pages
    boot.kernelParams = [
      "transparent_hugepage=madvise"
    ];

    # Enable Ananicy-cpp process priority daemon with CachyOS rulesets
    services.ananicy = lib.mkIf cfg.ananicy {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # Enable Sched-ext extensible CPU scheduler
    services.scx = lib.mkIf cfg.scx {
      enable = true;
      scheduler = "scx_bpfland";
    };

    # Global Vulkan / NVIDIA disk shader cache limit (10 GB)
    environment.sessionVariables = {
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    };
  };
}
