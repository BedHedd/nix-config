
{ config, pkgs, lib, ... }:

{
  # Enable SDDM & Plasma at the system level:
  services.displayManager.sddm.enable       = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable    = true;

  # Your KDE apps:
  environment.systemPackages = with pkgs; [
     kdePackages.dolphin      # Qt6-based Dolphin
     kdePackages.konsole      # Qt6-based Konsole
     kdePackages.kate         # Qt6-based Kate
     # more KDE apps, e.g. kdePackages.okular, etc.
   ];
}

