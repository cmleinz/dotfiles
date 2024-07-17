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
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "chili";
  };
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
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

  environment.systemPackages = with pkgs; [
    firefox

    # Dev Tools
    emacs
    # Can't seem to get jinx to compile natively
    emacsPackages.jinx
    hunspell
    hunspellDicts.en_US
    hunspellDicts.en_US-large

    enchant
    dconf
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
    pkg-config

    # Desktop Environment
    hyprlock
    hypridle
    hyprpaper
    networkmanagerapplet
    nwg-look
    sddm-chili-theme
    ironbar
    pcmanfm
    dunst
    fuzzel
    zathura
    waybar

    # Programming
    rustup
    clang
    clang-tools
    hare
    haredoc

    # Themeing
    la-capitaine-icon-theme
    capitaine-cursors
    pop-gtk-theme
    gtk4
    libadwaita

    # Applications
    discord
    spotify
    telegram-desktop
    nextcloud-client
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
