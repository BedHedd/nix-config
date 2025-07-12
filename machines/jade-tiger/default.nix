{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.gigabyte-b550

    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../users/admin.nix
    ../../users/dev.nix
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

  # jade-tiger specific tweeks  
  boot.kernelParams = [ 
    # "video=DP-1:3840x2160@60"
    "video=DP-2:3840x2160@60"
    #"video=DP-3:3840x2160@60"
    #"video=HDMI-A-1:2560x1440@59.95"
  ];

  services.udev.extraRules = ''
  # Disable wake for every AMD PCIe bridge
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{class}=="0x0604*", \
    ATTR{power/wakeup}="disabled"

  # Disable wake for AMD xHCI controllers
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{class}=="0x0c0330", \
    ATTR{power/wakeup}="disabled"

  # Disable wake for Realtek LAN on Gigabyte boards
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10ec", ATTR{device}=="0x8168", \
    ATTR{power/wakeup}="disabled"
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion  = "24.11";
}
