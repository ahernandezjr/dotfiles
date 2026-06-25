# Base system config (moved from common/configuration.nix). Applied to every host.
{ config, lib, pkgs, inputs, ... }:

{
  options.systemSettings.minimal = {
    enable = lib.mkEnableOption "Minimal system profile without GUI and heavy desktop services";
  };

  config = {
    boot = {
      loader = {
        limine = {
          enable = lib.mkDefault (!config.systemSettings.minimal.enable);
          efiSupport = lib.mkDefault (!config.systemSettings.minimal.enable);
          secureBoot.enable = lib.mkDefault (!config.systemSettings.minimal.enable);
        };  
        grub.enable = lib.mkDefault false;
      };

      supportedFilesystems = lib.mkDefault [ "btrfs" "ext" "ntfs" ];
    };

    hardware = {
      graphics.enable = lib.mkDefault (!config.systemSettings.minimal.enable);
      enableRedistributableFirmware = true;
      bluetooth.enable = true;
    };

    systemd.services.NetworkManager-wait-online.enable = false;


    networking = {
      hostName = lib.mkDefault "nixos";
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 25555 30000 ];
      };
    };

    # Nix binary caches and flake registry
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cachyos.cachix.org"
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cachyos.cachix.org-1:f/sS2icLGBP65963X54dz26wXxl4M93LAd6BGL+V3S4="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      trusted-users = [ "root" "@wheel" ];
    };

    # Pin default nixpkgs to our flake input so nix search / nix shell nixpkgs#... use nixos-unstable.
    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    # nixpkgs config is set when creating the nixpkgs instance in flake.nix.

    # Audio
    services.pulseaudio.enable = lib.mkDefault false;
    security.rtkit.enable = lib.mkDefault (!config.systemSettings.minimal.enable);
    services.pipewire = {
      enable = lib.mkDefault (!config.systemSettings.minimal.enable);
      alsa.enable = lib.mkDefault (!config.systemSettings.minimal.enable);
      alsa.support32Bit = lib.mkDefault (!config.systemSettings.minimal.enable);
      pulse.enable = lib.mkDefault (!config.systemSettings.minimal.enable);
    };

    # Power Settings
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    # Locale
    time.timeZone = "America/Chicago";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    services.libinput.mouse.middleEmulation = false;

    services.xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    users.users.alex = {
      isNormalUser = true;
      description = "alex";
      extraGroups = [ "networkmanager" "wheel" "video" "render" ];
      packages = with pkgs; [ tree ];
      shell = pkgs.fish;
    };

    environment.systemPackages = with pkgs; [
      vim 
      wget
      pciutils
      neovim
      fish
      gh
      jq
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ] ++ lib.optionals (!config.systemSettings.minimal.enable) [
      sbctl
      alacritty
      ghostty
      xwayland-satellite
    ];

    programs.fish.enable = true;

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 5";
    };

    services.dbus.implementation = "broker";

    services.gvfs.enable = lib.mkDefault (!config.systemSettings.minimal.enable);

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      SHELL = "fish";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    system.stateVersion = "26.05";
  };
}
