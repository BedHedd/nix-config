{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux

    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../users/bedhedd.nix
    nixos-hardware.nixosModules.common-gpu-nvidia
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
  
  boot = {
  initrd.kernelModules = [ "nvidia" "i915" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  kernelParams = [ "nvidia-drm.fbdev=1" ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      # optional but nice to have:
      # extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl intel-media-driver nvidia-vaapi-driver ];
    };

    xpadneo = {
      enable = true;
    };
    xone = {
      enable = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      forceFullCompositionPipeline = true;

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };

      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [ linuxKernel.packages.linux_zen.xone ];
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings = {
      General = {
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = "true";
      };
    };
  };
  
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';
  system.stateVersion = "25.05";
}
