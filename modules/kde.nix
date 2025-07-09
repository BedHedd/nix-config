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

  # 3) Drop your custom “VSCodium (Folder)” desktop globally
  xdg.desktopEntries.vscodium-folder = {
    name        = "VSCodium (Folder)";
    genericName = "Source-code Editor";
    exec        = "codium %F";
    icon        = "codium";
    mimeType    = [ "inode/directory" ];
    categories  = [ "Utility" "Development" "TextEditor" "IDE" ];
    terminal    = false;
  };

  # 4) Register it with XDG so it shows up in “Open With…”
  xdg.mime = {
    enable = true;

    # keep Dolphin as the default folder opener
    defaultApplications = {
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
    };

    # but also add VSCodium to the “Open With” list
    addedAssociations = {
      "inode/directory" = [ "vscodium-folder.desktop" ];
    };
  };
}
