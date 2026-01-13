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

  # Autostart Firefox in kiosk mode via XDG autostart
  environment.etc."xdg/autostart/media-center.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Media Center
    Exec=sh -c "sleep 3 && firefox --kiosk file:///home/user/dashboard.html"
    X-GNOME-Autostart-enabled=true
  '';

  # Autostart command server
  environment.etc."xdg/autostart/command-server.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Command Server
    Exec=python3 /home/user/command-server.py
    X-GNOME-Autostart-enabled=true
  '';

  # Autostart unclutter to hide mouse
  environment.etc."xdg/autostart/unclutter.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Unclutter
    Exec=unclutter -idle 3
    X-GNOME-Autostart-enabled=true
  '';

  system.stateVersion = "24.11"; 
}