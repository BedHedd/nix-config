# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, home-manager, plasma-manager, ... }:

{
  imports =
    [
      ../../modules/kde.nix
      ../../modules/steamdeck-plasma-system.nix
      nixos-hardware.nixosModules.common-gpu-amd
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager
      ./users.nix
    ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;

      # helper to find the handle: set edk2-uefi-shell.enable = true,
      # rebuild, boot the shell, run  `map -c`, then `ls HD0c3:\EFI`
      windows."10" = {
        title           = "Windows 10";
        efiDeviceHandle = "HD0c3";   # whatever handle lists the Microsoft dir
        sortKey         = "o_windows";
      };
    };
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;



  networking.hostName = "master-of-cooling"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  fileSystems."/mnt/sda1" = {
    device  = "/dev/disk/by-uuid/027f2550-4813-20d9-ac54-fc87dc4612eb";
    fsType  = "btrfs";

    # Fine-tune options to taste.  Good defaults for a personal btrfs data disk:
    options = [
      "compress=zstd"    # transparent compression
      "noatime"          # don’t update atime on every read
      "ssd"              # if the drive is actually an SSD
      # For a plug-in USB disk add:
      # "noauto" "x-systemd.automount"
    ];
  };

  fileSystems."/home/bedhedd/Documents" = {
    device  = "/mnt/sda1/Documents";
    options = [ "bind" ];
    depends = [ "/mnt/sda1" ];   # be sure the disk is mounted first
  };

  fileSystems."/home/bedhedd/Downloads" = {
    device  = "/mnt/sda1/Downloads";
    options = [ "bind" ];
    depends = [ "/mnt/sda1" ];
  };

  fileSystems."/home/bedhedd/Music" = {
    device  = "/mnt/sda1/Music";
    options = [ "bind" ];
    depends = [ "/mnt/sda1" ];
  };
  
  fileSystems."/home/bedhedd/Pictures" = {
    device  = "/mnt/sda1/Pictures";
    options = [ "bind" ];
    depends = [ "/mnt/sda1" ];
  };

  fileSystems."/home/bedhedd/Videos" = {
    device  = "/mnt/sda1/Videos";
    options = [ "bind" ];
    depends = [ "/mnt/sda1" ];
  };

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
#   services.xserver.xkb = {
#     layout = "us";
#     variant = "";
#   };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bedhedd = {
    isNormalUser = true;
    description = "bedhedd";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Home‑Manager setup for plasma‑manager

  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  home-manager.sharedModules = [
    plasma-manager.homeManagerModules."plasma-manager"
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
