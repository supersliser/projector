{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-media";
  networking.networkmanager.enable = true;

  # Enable Unfree Packages (Crucial for Netflix/Widevine DRM)
  nixpkgs.config.allowUnfree = true;

  # Graphics & Hardware Acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  # Sound (PipeWire)
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User setup
  users.users.user = {
    isNormalUser = true;
    description = "Media Center User";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [
      google-chrome
      pavucontrol
      jellyfin-media-player
      git
      vim
      python3
      unclutter
      steam
    ];
  };

  # Enable Steam hardware support
  programs.steam.enable = true;

  # Firefox with policies - auto-opens dashboard as homepage
  programs.firefox = {
    enable = true;
    policies = {
      Homepage = {
        URL = "file:///home/user/dashboard.html";
        Locked = false;
        StartPage = "homepage";
      };
      OverrideFirstRunPage = "file:///home/user/dashboard.html";
      OverridePostUpdatePage = "file:///home/user/dashboard.html";
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
    };
  };

  # GNOME Desktop
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
  };

  services.displayManager = {
    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "user";
    };
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Create startup script for autostarting applications
  environment.etc."profile.d/media-center-startup.sh".text = ''
    #!/bin/bash
    if [ "$(id -u)" -ne 0 ]; then
      # Only run for non-root users
      ${pkgs.firefox}/bin/firefox --kiosk file:///home/user/dashboard.html &
      sleep 2
      ${pkgs.python3}/bin/python3 /home/user/command-server.py &
      ${pkgs.unclutter}/bin/unclutter -idle 3 &
    fi
  '';

  # Enable SSH for debugging (optional)
  services.openssh.enable = true;

  system.stateVersion = "24.11"; 
}