# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:

{
  programs.plasma = {
    enable = true;

    # — Steam Deck global theme —
    workspace.lookAndFeel = lib.mkForce "com.valve.vapor.desktop";

    # — Declarative Steam Deck panel (auto‑hide, no floating) —
    panels = lib.mkForce [
      {
        location = "bottom";
        screen   = 0;
        height   = 64;
        floating = false;
        hiding   = "autohide";

        widgets = [
          {
            plasmoid = "org.kde.plasma.kickoff";
            config.General.icon                     = "distributor-logo-steamdeck";
            config.General.favoritesPortedToKAstats = true;
          }

          { plasmoid = "org.kde.plasma.pager"; }
          { plasmoid = "org.kde.plasma.icontasks"; }
          { plasmoid = "org.kde.plasma.marginsseparator"; }

          {
            plasmoid = "org.kde.plasma.systemtray";
            config.General.SystrayContainmentId = 166;
          }

          { plasmoid = "org.kde.plasma.digitalclock"; }
          { plasmoid = "org.kde.plasma.showdesktop"; }
        ];
      }
    ];

    # Example custom hotkey (unchanged)
    hotkeys.commands."launch-konsole" = {
      name    = "Launch Konsole";
      key     = "Meta+Alt+K";
      command = "konsole";
    };
  };
}



