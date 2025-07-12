{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.linux
    nixos-hardware.nixosModules.lenovo-thinkpad-e470
    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../users/bedhedd.nix
    ];

  networking.hostName  = host;
  my.isLaptop          = true;

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


  system.stateVersion  = "25.05";
}
