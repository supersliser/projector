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
    ];
  };

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

  # Autostart services using systemd user services (more reliable than XDG autostart with autologin)
  systemd.user.services.firefox-media-center = {
    enable = true;
    Unit.Description = "Firefox Media Center";
    Unit.After = [ "graphical-session-pre.target" ];
    Unit.PartOf = [ "graphical-session.target" ];
    Service.Type = "simple";
    Service.ExecStart = "${pkgs.firefox}/bin/firefox --kiosk file:///home/user/dashboard.html";
    Service.Restart = "on-failure";
    Service.RestartSec = 5;
    Service.Environment = "DISPLAY=:0";
  };

  systemd.user.services.command-server = {
    enable = true;
    Unit.Description = "Command Server";
    Unit.After = [ "graphical-session-pre.target" ];
    Unit.PartOf = [ "graphical-session.target" ];
    Service.Type = "simple";
    Service.ExecStart = "${pkgs.python3}/bin/python3 /home/user/command-server.py";
    Service.Restart = "on-failure";
    Service.RestartSec = 5;
  };

  systemd.user.services.unclutter = {
    enable = true;
    Unit.Description = "Unclutter Mouse";
    Unit.After = [ "graphical-session-pre.target" ];
    Unit.PartOf = [ "graphical-session.target" ];
    Service.Type = "simple";
    Service.ExecStart = "${pkgs.unclutter}/bin/unclutter -idle 3";
    Service.Restart = "on-failure";
    Service.RestartSec = 5;
    Service.Environment = "DISPLAY=:0";
  };

  system.stateVersion = "24.11"; 
}