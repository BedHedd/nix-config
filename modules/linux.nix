# modules/linux.nix
{ config, pkgs, lib, ... }:

{
  # ── Conditional imports as a list ─────────────────────────────────────
  imports = lib.optionals pkgs.stdenv.isLinux [
    ../modules/kde.nix
    ../modules/steamdeck-plasma-system.nix
  ];

  # ── Boot & kernel ───────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages                  = pkgs.linuxPackages_latest;

  # ── Core services ──────────────────────────────────────────────────────
  networking.networkmanager.enable     = true;

  services.displayManager.sddm.enable         = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable      = true;

  services.printing.enable   = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── Power management on laptop vs. desktop ─────────────────────────────
  services.tlp.enable = lib.mkIf config.my.isLaptop true;
  services.tlp.settings = lib.mkIf config.my.isLaptop {
    CPU_SCALING_GOVERNOR_ON_AC  = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    START_CHARGE_THRESH_BAT0    = 40;
    STOP_CHARGE_THRESH_BAT0     = 80;
  };
  services.power-profiles-daemon.enable =
    lib.mkIf (!config.my.isLaptop) true;
}
