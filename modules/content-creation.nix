{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obs-studio # screen recording
    obs-studio-plugins.obs-vkcapture # Game capture
    obs-studio-plugins.advanced-scene-switcher # scene switcher
    # obs-studio-plugins.obs-multi-rtmp # simulcasting/multistream
    ffmpeg # video encoding
    vlc # media playback
    kdePackages.kdenlive # video editing
    krita # image manipulation
  ];
}
