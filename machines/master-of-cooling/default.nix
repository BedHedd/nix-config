{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux
    nixos-hardware.nixosModules.common-gpu-amd

    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../users/bedhedd.nix
    ];

  networking.hostName  = host;
  my.isLaptop          = false;

  time.timeZone        = "America/Chicago";
  i18n.defaultLocale  = "en_US.UTF-8";
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

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    # ONE line → menu entry called “11” pointing at fs2:
    systemd-boot.windows."10".efiDeviceHandle = "FS2";
    systemd-boot.configurationLimit = 8;
  };

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

  system.stateVersion  = "25.05";
}
