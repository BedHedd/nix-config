# modules/linux.nix
{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  imports = [
    ../modules/kde.nix                # your plasma stack
    ../modules/steamdeck-plasma-system.nix
  ];

  # ─ Boot & kernel
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages                  = pkgs.linuxPackages_latest;

  # ─ Core services
  networking.networkmanager.enable     = true;

  services.displayManager.sddm.enable      = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable      = true;

  services.printing.enable   = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable        = true;
    alsa.enable   = true;
    alsa.support32Bit = true;
    pulse.enable  = true;
  };

  # ─ Power (laptop only; see note)
  lib.mkIf pkgs.stdenv.isLinux {

  # …imports, boot, Plasma, PipeWire, etc…

  # ── Power management conditional on my.isLaptop ───────────────────
  services.tlp = lib.mkIf config.my.isLaptop {
    enable   = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0    = 40;
      STOP_CHARGE_THRESH_BAT0     = 80;
    };
  };

  # Desktops get the lighter daemon instead
  services.power-profiles-daemon.enable =
    lib.mkIf (!config.my.isLaptop) true;
}

  # leave users and hardware-configuration.nix to each host file
}
