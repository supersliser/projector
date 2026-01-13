{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader (Adjust if you use GRUB)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-media";
  networking.networkmanager.enable = true;

  # 1. Enable Unfree Packages (Crucial for Netflix/Widevine DRM)
  nixpkgs.config.allowUnfree = true;

  # 2. Graphics & Hardware Acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Intel iGPUs
      libvdpau-va-gl
      # vaapiVdpau # Uncomment if using older NVIDIA
    ];
  };

  # 3. Sound (PipeWire is modern and stable)
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 4. Auto-Login User setup
  users.users.user = {
    isNormalUser = true;
    description = "Media Center User";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [
      google-chrome # Fallback if Firefox DRM acts up
      pavucontrol   # Audio control GUI
      jellyfin-media-player # Excellent for local media (replaces Kodi)
      git
      vim
      python3       # For command server
    ];
  };

  # 5. Firefox with policies - auto-opens dashboard
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
      NewTabPage = false;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
    };
  };

  # 6. Display Server (GNOME Desktop)
  # Using GNOME for full desktop functionality when needed
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
  };

  services.displayManager = {
    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "user";
    };
  };

  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;  # Prevent auto-suspend for media center use
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # 7. Hide the mouse cursor after inaction (Clutter-free TV experience)
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.unclutter}/bin/unclutter -idle 3 &
  '';

  # 8. GNOME autostart for Firefox in kiosk mode
  environment.etc."xdg/autostart/media-center.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Media Center
    Exec=firefox --kiosk
    X-GNOME-Autostart-enabled=true
    X-GNOME-Autostart-Delay=3
  '';

  # 9. Command server for power controls
  systemd.user.services.command-server = {
    description = "Media Center Command Server";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /home/user/command-server.py";
      Restart = "on-failure";
    };
  };

  system.stateVersion = "24.11"; 
}