# modules/linux.nix
{ config, pkgs, lib, plasma-manager, ... }:

{
  #######################################################################
  # 1. Flag declaring laptop/desktop                                    #
  #######################################################################
  options.my.isLaptop = lib.mkOption {
    type        = lib.types.bool;
    default     = false;
    description = "Whether this Linux host is a laptop (enables TLP)";
  };

  #######################################################################
  # 2. Extra system modules to import                                   #
  #######################################################################
  imports = [
    ../modules/kde.nix
    ../modules/steamdeck-plasma-system.nix
    ../modules/entertainment.nix
  ];

  #######################################################################
  # 3. System-wide configuration                                        #
  #######################################################################
  config = {

    ####################   Home-Manager glue   ####################
    home-manager.sharedModules = [
      plasma-manager.homeModules."plasma-manager"  # provides `programs.plasma`
      ../modules/kde-home.nix                             # your own Plasma tweaks
    ];

    ####################   Boot & kernel   ####################
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages                  = pkgs.linuxPackages_latest;

    ####################   Core services   ####################
    networking.networkmanager.enable = true;

    services.displayManager.sddm = {
      enable         = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    services.printing.enable   = true;
    services.pulseaudio.enable = false;
    security.rtkit.enable      = true;

    services.pipewire = {
      enable            = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
    };

    ####################   Power management   ####################
    services.tlp.enable = config.my.isLaptop;
    services.tlp.settings = lib.mkIf config.my.isLaptop {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0    = 40;
      STOP_CHARGE_THRESH_BAT0     = 80;
    };

    services.power-profiles-daemon.enable = !config.my.isLaptop;

    services.clamav.daemon.enable = true;
    services.clamav.updater.enable = true;
  };
}
