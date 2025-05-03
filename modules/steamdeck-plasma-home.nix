# modules/steamdeck-plasma-home.nix
{ lib, ... }:

{
  programs.plasma = {
    enable = true;

    # This outranks any other definition:
    workspace.lookAndFeel = lib.mkForce "org.kde.vapor.desktop";
  };
}

