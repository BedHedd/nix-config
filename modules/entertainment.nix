{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
    steam-run
    #lutris
    vlc
  ];
}
