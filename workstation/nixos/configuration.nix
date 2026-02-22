# Edit this configuration file to define what should be installed

{ config, pkgs, ... }:

{
  imports =
    [
    	./hardware-configuration.nix
    ];


  # Bootloader.
  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.biosDevice = "/dev/nvme0n1";
  # boot.loader.limine.installDevice = "/dev/sda1";
  # boot.loader.grub.useOSProber = true;
  boot.loader.grub.enable = false;

  hardware = {
  	graphics.enable = true;
	enableRedistributableFirmware = true; # may be useless
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    	tree
    ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
  	vim
	wget
	neovim
	fish
	alacritty
	ghostty
	xwayland-satellite
	gh
	floorp-bin
  ];

  programs.niri.enable = true;
  programs.fish.enable = true;

  environment.sessionVariables = {
  	EDITOR = "nvim";
	TERMINAL = "alacritty";
	SHELL = "fish";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
	services.greetd = {
		enable = true;

		settings = {
			default_session = {
				command = "${pkgs.niri}/bin/niri";
				user = "alex";
			};
		};
	};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
