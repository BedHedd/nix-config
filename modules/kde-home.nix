# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  wpDir = "${config.home.homeDirectory}/Pictures/desktop_backgrounds";
in {
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "com.valve.vgui.desktop";

    # Desktop & lock screen slideshows — 15 minutes
    workspace.wallpaperSlideShow = {
      path     = wpDir;
      interval = 900;
    };
    kscreenlocker.appearance.wallpaperSlideShow = {
      path     = wpDir;
      interval = 900;
    };

    # Night Light
    kwin.nightLight = {
      enable = true;
      mode = "location";
      location.latitude  = "41.8781";
      location.longitude = "-87.6298";
      temperature.day   = 6500;
      temperature.night = 4500;
      transitionTime    = 30;
    };

    # Keep widgets as plain strings (broadly compatible)
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";

        widgets = [
          "org.kde.plasma.kickoff"          # 99
          "org.kde.plasma.pager"            # 100
          "org.kde.plasma.icontasks"        # 101
          "org.kde.plasma.systemmonitor.net"# 126
          "org.kde.plasma.systemmonitor.cpucore" # 123
          "org.kde.plasma.systemmonitor.cpucore" # 124
          "org.kde.plasma.systemmonitor.memory"  # 125
          "org.kde.plasma.marginsseparator" # 102
          "org.kde.plasma.systemtray"       # 103
          "org.kde.plasma.digitalclock"     # 116
          "org.kde.plasma.showdesktop"      # 117
        ];
      }
    ];

    # KConfig overrides that Plasma-Manager will merge into appletsrc
    # (These mirror the sections from your pasted file.)
    configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
      # Panel order
      "Containments][98][General".AppletOrder =
        "99;100;101;126;123;124;125;102;103;116;117";

      # Kickoff icon
      "Containments][98][Applets][99][Configuration][General".icon =
        "distributor-logo-steamdeck";

      # Icon Tasks launchers (preferred handlers + Strawberry)
      "Containments][98][Applets][101][Configuration][General".launchers =
        "preferred://browser,preferred://filemanager,applications:org.strawberrymusicplayer.strawberry.desktop";

      # System Monitor: Network (title + face)
      "Containments][98][Applets][126][Configuration][Appearance".chartFace =
        "org.kde.ksysguard.linechart";
      "Containments][98][Applets][126][Configuration][Appearance".title =
        "Network Speed";

      # System Monitor: CPU cores
      "Containments][98][Applets][123][Configuration][Appearance".chartFace =
        "org.kde.ksysguard.barchart";
      "Containments][98][Applets][123][Configuration][Appearance".title =
        "Individual Core Usage";

      # System Monitor: GPU “cores”
      "Containments][98][Applets][124][Configuration][Appearance".chartFace = "org.kde.ksysguard.piechart";
      "Containments][98][Applets][124][Configuration][Appearance".title     = "Individual GPU Core Usage";

      # Use a generic GPU regex so it works whether your card shows as gpu0 or gpu1
      "Containments][98][Applets][124][Configuration][Sensors".highPrioritySensorIds =
        ''["gpu/gpu.*/usage","gpu/gpu.*/temperature"]'';
      "Containments][98][Applets][124][Configuration][Sensors".totalSensors =
        ''["gpu/gpu.*/usage"]'';

      # FaceGrid block (the applet is using a FaceGrid internally; make it GPU too)
      "Containments][98][Applets][124][Configuration][FaceGrid][Appearance".chartFace = "org.kde.ksysguard.linechart";
      "Containments][98][Applets][124][Configuration][FaceGrid][Appearance".showTitle = "false";
      "Containments][98][Applets][124][Configuration][FaceGrid][Sensors".highPrioritySensorIds =
        ''["gpu/gpu.*/usage"]'';

      # (Optional) Colors for common GPU signals — safe to keep or remove
      "Containments][98][Applets][124][Configuration][SensorColors"."gpu/gpu.*/usage"        = "62,49,149";
      "Containments][98][Applets][124][Configuration][SensorColors"."gpu/gpu.*/temperature"  = "93,149,49";

      # Memory applet
      "Containments][98][Applets][125][Configuration][Appearance".chartFace =
        "org.kde.ksysguard.piechart";
      "Containments][98][Applets][125][Configuration][Appearance".title =
        "Memory Usage";
    };
  };

  # VSCodium desktop entry override
  xdg.desktopEntries.vscodium = {
    name        = "VSCodium";
    genericName = "Source-code Editor";
    exec        = "codium %F";
    icon        = "vscodium";
    mimeType    = [ "inode/directory" ];
    categories  = [ "Utility" "Development" "TextEditor" "IDE" ];
    terminal    = false;
  };

  # MIME associations
  xdg.mimeApps = {
    enable = true;
    associations.added."inode/directory"  = [ "vscodium.desktop" ];
    defaultApplications."inode/directory" = [ "org.kde.dolphin.desktop" ];
  };
}
