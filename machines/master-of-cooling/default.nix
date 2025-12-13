{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux
    # modules.rocksmith
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

 fileSystems."/mnt/GamezDrive" = {
   device  = "/dev/disk/by-uuid/e8aff502-720e-4f90-9f4b-a6ab13bfd9a3";
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
  
 fileSystems."/home/bedhedd/GamezDrive" = {
   device  = "/mnt/GamezDrive";
   options = [ "bind" ];
   depends = [ "/mnt/GamezDrive" ];
 };
 
 systemd.tmpfiles.rules = [
    # Steam data on GamezDrive
    "d /home/bedhedd/GamezDrive 0755 bedhedd users -"
    "d /home/bedhedd/GamezDrive/steam-linux 0755 bedhedd users -"
    "d /home/bedhedd/GamezDrive/steam-linux/steamapps 0755 bedhedd users -"

    # Steam folder in $HOME
    "d /home/bedhedd/.steam 0755 bedhedd users -"
    "d /home/bedhedd/.steam/steam 0755 bedhedd users -"
  ];
  
  fileSystems."/home/bedhedd/.steam/steam/steamapps" = {
    device  = "/home/bedhedd/GamezDrive/steam-linux/steamapps";
    options = [
      "bind"
      "nofail"              # don’t fail the boot if this mount fails
    ];
    # Ensure the GamezDrive mount is set up first
    depends = [ "/home/bedhedd/GamezDrive" ];
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
  
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
  };
  users.groups.ollama = {};
  
  services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      environmentVariables = {
        OLLAMA_MODELS = "/mnt/sda1/Documents/ollama-models";  # <-- custom model dir
      };
    models  = "/mnt/sda1/Documents/ollama-models";  # <-- custom model dir
  };

  services.llama-cpp = {
      # enable = true;
      model  = "/mnt/sda1/Documents/ollama-models/llama-cpp-models";  # <-- custom model dir
  };

   virtualisation.virtualbox.host = {
    enable = true;

    # Optional but usually needed for USB support etc.
    enableExtensionPack = true;
  };
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;
  users.extraGroups.vboxusers.members = [ "bedhedd" ];
  virtualisation.virtualbox.host.enableHardening = false;
  virtualisation.spiceUSBRedirection.enable = true;

}
