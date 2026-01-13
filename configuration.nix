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
      firefox
      google-chrome # Fallback if Firefox DRM acts up
      pavucontrol   # Audio control GUI
      jellyfin-media-player # Excellent for local media (replaces Kodi)
      git
      vim
      python3       # For command server
    ];
  };

  # 5. Display Server (GNOME Desktop)
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

  # 6. Hide the mouse cursor after inaction (Clutter-free TV experience)
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.unclutter}/bin/unclutter -idle 3 &
  '';

  # 7. Media Center Autostart - System service that runs after login
  systemd.user.services.media-center = {
    description = "Media Center Dashboard";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.bash}/bin/bash /home/user/media-center.sh";
    };
  };

  system.stateVersion = "24.11"; 
}