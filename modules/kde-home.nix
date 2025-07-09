# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:

{
  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = lib.mkForce "com.valve.vapor.deck.desktop";

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

  home.file."${config.xdg.configHome}/applications/vscodium-folder.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=VSCodium (Folder)
    Exec=codium %F
    Icon=codium
    MimeType=inode/directory;
    NoDisplay=true
  '';

  home.xdg.mimeApps = {
    enable = true;

    # this goes in the “Open With” list
    addedAssociations = {
      "inode/directory" = [ "vscodium-folder.desktop" ];
    };

    # optional: make it your default instead of dolphin
    defaultApplications = {
      "inode/directory" = [ "vscodium-folder.desktop" ];
    };
  };
  
  # Override Kickoff’s icon at the KConfig level
}


