# machines/jade-tiger/home.nix
{ pkgs, plasma-manager, ... }:

{
  # import your global home.nix (fonts, fish, etc.)
  imports = [ ../../modules/home.nix ];

  # now configure plasma via the plasma-manager HM module:
  programs.plasma.enable = true;

  programs.plasma.workspace = {
    clickItemTo = "select";
    lookAndFeel = "org.kde.breezedark.desktop";
    # cursor.theme = "Bibata-Modern-Ice";
    # iconTheme   = "Papirus-Dark";
    # wallpaper   = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
  };

  programs.plasma.hotkeys.commands."launch-konsole" = {
    name    = "Launch Konsole";
    key     = "Meta+Alt+K";
    command = "konsole";
  };

  programs.plasma.panels = [
    {
      location = "bottom";
      widgets = [
        "org.kde.plasma.kickoff"
        "org.kde.plasma.icontasks"
        "org.kde.plasma.marginsseparator"
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock"
      ];
    }
  ];

  # …more programs.plasma.* settings as desired…
}

