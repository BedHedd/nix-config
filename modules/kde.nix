
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

 # 1) Drop the desktop file globally
  environment.etc."xdg/applications/vscodium-folder.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=VSCodium (Folder)
    Exec=codium %F
    Icon=codium
    MimeType=inode/directory;
    NoDisplay=true
  '';

  # 2) Tell XDG to add it to the “Open With…” list
  xdg.mime = {
    enable = true;

    # keep dolphin if you like…
    defaultApplications = {
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
    };

    # …but also add codium
    addedAssociations = {
      "inode/directory" = [ "vscodium-folder.desktop" ];
    };

  };
 
}

