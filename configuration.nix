# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.sddm.theme = "elegant-sddm";
  };
  services.dbus.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  users.users.caleb = {
    isNormalUser = true;
    description = "Caleb Leinz";
    shell = pkgs.nushell;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
  ];

  environment.systemPackages = with pkgs; [
    firefox

    # Dev Tools
    emacs
    helix
    neovim
    fzf
    ripgrep
    nushell
    carapace
    alacritty
    zellij
    zoxide
    eza
    starship
    jujutsu
    git
    stow

    # Desktop Environment
    hyprlock
    hypridle
    hyprpaper
    networkmanagerapplet
    elegant-sddm
    ironbar
    pcmanfm
    dunst
    fuzzel
    zathura

    # Applications
    discord
    spotify
    telegram-desktop
    nextcloud-client
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
