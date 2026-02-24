# Base system config (moved from common/configuration.nix). Applied to every host.
{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
  };
  boot.loader.grub.enable = false;

  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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
