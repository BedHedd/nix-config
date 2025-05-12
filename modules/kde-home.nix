# modules/kde-home.nix
{ pkgs, plasma-manager, lib, ... }:

{
  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = lib.mkForce "com.valve.vapor.deck.desktop";

    panels = lib.mkForce [
      {
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
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".text = lib.mkForce ''
    [Containments][1][Applets][1][Configuration][General]
    icon=distributor-logo-steamdeck
  '';
}


