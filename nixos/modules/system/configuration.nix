# Base system config (moved from common/configuration.nix). Applied to every host.
{ config, pkgs, ... }:

{
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
  };
  boot.loader.grub.enable = false;

  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Nix binary caches
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.alex = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    vim wget neovim fish alacritty ghostty xwayland-satellite gh floorp-bin
  ];

  programs.fish.enable = true;

  environment.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    SHELL = "fish";
  };

  system.stateVersion = "25.11";
}
