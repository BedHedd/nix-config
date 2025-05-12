# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:

{
  programs.plasma = {
    enable = true;

    workspace = {
      clickItemTo = "select";
      lookAndFeel = lib.mkForce "com.valve.vapor.deck.desktop";
      # lookAndFeel  = "org.kde.breezedark.desktop";
      # …
    };

    hotkeys.commands."launch-konsole" = {
      name    = "Launch Konsole";
      key     = "Meta+Alt+K";
      command = "konsole";
    };

    panels = [
      {
        location = "bottom";
        widgets  = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}

