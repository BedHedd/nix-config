{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux

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

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/1a6e824d-98b7-4c86-b6bd-ba0c5316f033";
    fsType  = "btrfs";

    options = [
      "compress=zstd"    # transparent compression
      "noatime"          # don’t update atime on every read
      "ssd"              # if the drive is actually an SSD
      # For a plug-in USB disk add:
      # "noauto" "x-systemd.automount"
    ];    
  };


  system.stateVersion = "25.05";
}
