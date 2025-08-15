# modules/kde.nix

{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # 1) Enable SDDM & Plasma (only on Linux)
  services.displayManager.sddm.enable         = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable      = true;

  # 2) Install Dolphin, Kate, Konsole—and VSCodium itself
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.kate
    vscodium
  ];
}
