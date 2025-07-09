{ config, pkgs, lib, ...}:

{
  # 1) Enable SDDM & Plasma
  services.displayManager.sddm.enable        = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable     = true;

  # 2) Install Dolphin, Kate, Konsole—and VSCodium itself
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.kate
    vscodium                         # ← make sure codium exists
  ];

}
