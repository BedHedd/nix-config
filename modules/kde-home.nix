# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:


programs.plasma = {
  enable = true;
  workspace.lookAndFeel = lib.mkForce "com.valve.vapor.deck.desktop";

  # force exactly one Deck‑style panel each login
  panels = lib.mkForce [
    {
      location   = "bottom";   # 0 = top, 1 = left, 2 = right, 4 = bottom
      screen     = 0;          # primary monitor
      height     = 64;
      floating   = false;      # disable floating panel
      visibility = "AutoHide"; # AutoHide | LetWindowsCover | WindowsGoBelow

      widgets = [
        # Kickoff (Steam icon)
        {
          plugin = "org.kde.plasma.kickoff";
          configuration = {
            General = {
              icon = "distributor-logo-steamdeck";   # Steam Deck logo
              favoritesPortedToKAstats = true;
            };
            popupHeight = 400;
            popupWidth  = 560;
          };
        }

        # Pager
        { plugin = "org.kde.plasma.pager"; }

        # Icon Tasks
        { plugin = "org.kde.plasma.icontasks"; }

        # Separator
        { plugin = "org.kde.plasma.marginsseparator"; }

        # System tray (with its own inner containment)
        {
          plugin = "org.kde.plasma.systemtray";
          configuration = {
            SystrayContainmentId = 166;
          };
        }

        # Digital clock
        {
          plugin = "org.kde.plasma.digitalclock";
          configuration = {
            popupHeight = 400;
            popupWidth  = 560;
          };
        }

        # Show desktop button (optional)
        { plugin = "org.kde.plasma.showdesktop"; }
      ];
    }
  ];
};

