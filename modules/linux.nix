# modules/linux.nix
{ config, pkgs, lib, ... }:

{
  #######################################################################
  # 1.  Declare the flag                                                 #
  #######################################################################
  options.my.isLaptop = lib.mkOption {
    type        = lib.types.bool;
    default     = false;
    description = "Whether this Linux host is a laptop (enables TLP)";
  };

  home-manager.sharedModules = [
    plasma-manager.homeManagerModules."plasma-manager"
  ];

  #######################################################################
  # 2.  Extra modules to import                                          #
  #######################################################################
  imports = [
    ../modules/kde.nix
    ../modules/steamdeck-plasma-system.nix
  ];

  #######################################################################
  # 3.  Actual system configuration (wrapped in `config = { … };`)       #
  #######################################################################
  config = {

    # ── Boot & kernel ────────────────────────────────────────────────
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages                  = pkgs.linuxPackages_latest;

    # ── Core services ────────────────────────────────────────────────
    networking.networkmanager.enable = true;

    services.displayManager.sddm = {
      enable         = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    services.printing.enable   = true;
    services.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable            = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
    };

    # ── Power management: laptop vs. desktop ─────────────────────────
    services.tlp.enable   = lib.mkIf config.my.isLaptop true;
    services.tlp.settings = lib.mkIf config.my.isLaptop {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0    = 40;
      STOP_CHARGE_THRESH_BAT0     = 80;
    };

    services.power-profiles-daemon.enable =
      lib.mkIf (!config.my.isLaptop) true;
  };
}
