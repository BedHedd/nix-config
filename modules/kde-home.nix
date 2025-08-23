# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:

{
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    workspace.lookAndFeel = "com.valve.vgui.desktop";


    kwin.nightLight = {
      enable = true;

      # Pick ONE of the following modes ↓

      ## 1. Always-on (“constant”)
      # mode = "constant";

      ## 2. Follow sunrise/sunset for your place (“location”)
      mode = "location";
      location.latitude  = "41.8781";   # ≈ Chicago – tweak if you’re elsewhere
      location.longitude = "-87.6298";

      ## 3. Fixed schedule (“times”)
      # mode = "times";
      # time.morning = "06:30";  # when Night Light turns *off*
      # time.evening = "19:30";  # when it turns *on*

      # Optional fine-tuning
      temperature.day   = 6500;  # K
      temperature.night = 4500;  # K
      transitionTime    = 30;    # minutes for the fade
      };

    panels = lib.mkForce [
      {
        screen = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        # hiding   = "autoHide";
        # visibility = "autohide";
        hiding   = "dodgewindows";

        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };  
  # Override Kickoff’s icon at the KConfig level
  # 1 ▸ the launcher itself
  xdg.desktopEntries.vscodium = {
    name        = "VSCodium";
    genericName = "Source-code Editor";
    exec        = "codium %F";
    icon        = "vscodium";
    mimeType    = [ "inode/directory" ];
    categories  = [ "Utility" "Development" "TextEditor" "IDE" ];
    terminal    = false;
  };

  # 2 ▸ MIME associations (***note the path***)
  xdg.mimeApps = {
    enable = true;

    associations.added."inode/directory"   = [ "vscodium.desktop" ];
    defaultApplications."inode/directory"  = [ "org.kde.dolphin.desktop" ];
  };

}


