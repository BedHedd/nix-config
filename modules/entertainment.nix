{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
    # steam-run
    #lutris
    ludusavi
    vlc
    whipper
    cyanrip
  ];
}
