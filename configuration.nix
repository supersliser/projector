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
    ];
  };

  # 5. Display Server (X11 + Openbox)
  # We use Openbox because it is lighter than GNOME/KDE and won't interfere with the browser.
  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
  };

  services.displayManager = {
    defaultSession = "openbox";
    autoLogin = {
      enable = true;
      user = "user";
    };
  };

  services.xserver.displayManager.lightdm.enable = true;

  # 6. Hide the mouse cursor after inaction (Clutter-free TV experience)
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.unclutter}/bin/unclutter -idle 3 &
  '';

  system.stateVersion = "24.11"; 
}