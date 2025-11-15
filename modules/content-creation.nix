{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obs-studio # screen recording
    obs-studio-plugins.advanced-scene-switcher
    ffmpeg # video encoding
    vlc # media playback
    kdePackages.kdenlive # video editing
    krita # image manipulation
  ];
}
