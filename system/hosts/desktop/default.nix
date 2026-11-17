{ config, pkgs, lib, inputs, self, ... }:

{
  imports = [ ./hardware-configuration.example.nix ];

  networking.hostName = "desktop";
  time.timeZone = "UTC";

  # Bootloader/filesystems are placeholders; replace hardware-configuration on real install.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.user = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.nushell;
  };

  programs.mango.enable = true; # MangoWC system integration (upstream module)

  # Desktop/session prerequisites (Wayland shell, portals, audio, etc.)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.dbus.enable = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "wlr" "gtk" ];
  };

  # Networking baseline
  networking.networkmanager.enable = lib.mkDefault true;

  # Required/common runtime tools for a Quickshell/MangoWC desktop (adjust per hardware/preferences)
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    foot
    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    networkmanagerapplet
    pavucontrol
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Enable display/login manager integration as appropriate for MangoWC in your environment.
  # services.greetd or a display manager can be configured here; compositor session is provided by MangoWC.

  system.stateVersion = "24.11"; # Adjust for target NixOS release
}
