# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  # Note the space in the folder name:
  wpDir = "${config.home.homeDirectory}/Pictures/desktop backgrounds";
in {
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "com.valve.vgui.desktop";

    # Desktop & lock screen slideshows — 15 minutes
    workspace.wallpaperSlideShow = { path = wpDir; interval = 900; };
    kscreenlocker.appearance.wallpaperSlideShow = { path = wpDir; interval = 900; };

    # Night Light (unchanged)
    kwin.nightLight = {
      enable = true;
      mode = "location";
      location.latitude  = "41.8781";
      location.longitude = "-87.6298";
      temperature.day   = 6500;
      temperature.night = 4500;
      transitionTime    = 30;
    };

    # Panel layout — keep plugin order in sync with AppletOrder below
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";
        widgets = [
          "org.kde.plasma.kickoff"                # 293
          "org.kde.plasma.pager"                  # 294
          "org.kde.plasma.icontasks"              # 295
          "org.kde.plasma.systemmonitor.net"      # 296
          "org.kde.plasma.systemmonitor.cpucore"  # 297
          "org.kde.plasma.systemmonitor.cpucore"  # 298 (GPU-focused instance)
          "org.kde.plasma.systemmonitor.memory"   # 299
          "org.kde.plasma.marginsseparator"       # 300
          "org.kde.plasma.systemtray"             # 301
          "org.kde.plasma.digitalclock"           # 314
          "org.kde.plasma.showdesktop"            # 315
        ];
      }
    ];

    # Exact KConfig mapped verbatim to your new snippet
    configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
      # Actions
      "[ActionPlugins][0]"."MiddleButton;NoModifier" = "org.kde.paste";
      "[ActionPlugins][0]"."RightButton;NoModifier"  = "org.kde.contextmenu";
      "[ActionPlugins][1]"."RightButton;NoModifier"  = "org.kde.contextmenu";

      # Desktop containment (289)
      "[Containments][289]".ItemGeometries-3840x2160 = "";
      "[Containments][289]".ItemGeometriesHorizontal = "";
      "[Containments][289]".activityId     = "78fd4f13-1901-4c5a-a627-88c183341bae";
      "[Containments][289]".formfactor     = 0;
      "[Containments][289]".immutability   = 1;
      "[Containments][289]".lastScreen     = 0;
      "[Containments][289]".location       = 0;
      "[Containments][289]".plugin         = "org.kde.plasma.folder";
      "[Containments][289]".wallpaperplugin = "org.kde.slideshow";
      "[Containments][289][General]".positions = ''{"3840x2160":[]}'';
      "[Containments][289][Wallpaper][org.kde.slideshow][General]".SlideInterval = 900;
      "[Containments][289][Wallpaper][org.kde.slideshow][General]".SlidePaths    = wpDir;

      # Panel containment (292)
      "[Containments][292]".activityId   = "";
      "[Containments][292]".formfactor   = 2;
      "[Containments][292]".immutability = 1;
      "[Containments][292]".lastScreen[$i] = 0;
      "[Containments][292]".location     = 4;
      "[Containments][292]".plugin       = "org.kde.panel";
      "[Containments][292]".wallpaperplugin = "org.kde.image";
      "[Containments][292][General]".AppletOrder =
        "293;294;295;296;297;298;299;300;301;314;315";

      # Kickoff (293)
      "[Containments][292][Applets][293]".plugin = "org.kde.plasma.kickoff";
      "[Containments][292][Applets][293][Configuration]".PreloadWeight = 100;
      "[Containments][292][Applets][293][Configuration]".popupHeight   = 508;
      "[Containments][292][Applets][293][Configuration]".popupWidth    = 647;
      "[Containments][292][Applets][293][Configuration][General]".favoritesPortedToKAstats = true;
      "[Containments][292][Applets][293][Configuration][General]".icon = "distributor-logo-steamdeck";

      # Pager (294)
      "[Containments][292][Applets][294]".plugin = "org.kde.plasma.pager";

      # Icon Tasks (295) — launcher change
      "[Containments][292][Applets][295]".plugin = "org.kde.plasma.icontasks";
      "[Containments][292][Applets][295][Configuration][General]".launchers =
        "preferred://browser,preferred://filemanager,applications:systemsettings.desktop";

      # System Monitor: Network (296)
      "[Containments][292][Applets][296]".plugin = "org.kde.plasma.systemmonitor.net";
      "[Containments][292][Applets][296][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][292][Applets][296][Configuration]".popupHeight   = 400;
      "[Containments][292][Applets][296][Configuration]".popupWidth    = 560;
      "[Containments][292][Applets][296][Configuration][Appearance]".chartFace = "org.kde.ksysguard.linechart";
      "[Containments][292][Applets][296][Configuration][Appearance]".title     = "Network Speed";
      "[Containments][292][Applets][296][Configuration][SensorColors]"."network/all/download" = "149,136,49";
      "[Containments][292][Applets][296][Configuration][SensorColors]"."network/all/upload"   = "49,62,149";
      "[Containments][292][Applets][296][Configuration][Sensors]".highPrioritySensorIds =
        ''["network/all/download","network/all/upload"]'';

      # System Monitor: CPU cores (297)
      "[Containments][292][Applets][297]".plugin = "org.kde.plasma.systemmonitor.cpucore";
      "[Containments][292][Applets][297][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][292][Applets][297][Configuration]".PreloadWeight = 60;
      "[Containments][292][Applets][297][Configuration]".popupHeight   = 386;
      "[Containments][292][Applets][297][Configuration]".popupWidth    = 306;
      "[Containments][292][Applets][297][Configuration][Appearance]".chartFace = "org.kde.ksysguard.barchart";
      "[Containments][292][Applets][297][Configuration][Appearance]".title     = "Individual Core Usage";
      "[Containments][292][Applets][297][Configuration][Sensors]".highPrioritySensorIds = ''["cpu/cpu.*/usage"]'';
      "[Containments][292][Applets][297][Configuration][Sensors]".totalSensors         = ''["cpu/all/usage"]'';
      "[Containments][292][Applets][297][Configuration][SensorColors]" = {
        "cpu/cpu.*/usage" = "149,136,49";
        "cpu/cpu0/usage"  = "149,136,49";
        "cpu/cpu1/usage"  = "125,149,49";
        "cpu/cpu2/usage"  = "87,149,49";
        "cpu/cpu3/usage"  = "50,149,49";
        "cpu/cpu4/usage"  = "49,149,86";
        "cpu/cpu5/usage"  = "49,149,124";
        "cpu/cpu6/usage"  = "49,137,149";
        "cpu/cpu7/usage"  = "49,100,149";
        "cpu/cpu8/usage"  = "49,62,149";
        "cpu/cpu9/usage"  = "74,49,149";
        "cpu/cpu10/usage" = "111,49,149";
        "cpu/cpu11/usage" = "149,49,149";
        "cpu/cpu12/usage" = "149,49,112";
        "cpu/cpu13/usage" = "149,49,75";
        "cpu/cpu14/usage" = "149,61,49";
        "cpu/cpu15/usage" = "149,99,49";
      };

      # System Monitor: second cpucore instance (298) — GPU-focused
      "[Containments][292][Applets][298]".plugin = "org.kde.plasma.systemmonitor.cpucore";
      "[Containments][292][Applets][298][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][292][Applets][298][Configuration]".PreloadWeight = 65;
      "[Containments][292][Applets][298][Configuration]".popupHeight   = 240;
      "[Containments][292][Applets][298][Configuration]".popupWidth    = 271;
      "[Containments][292][Applets][298][Configuration][Appearance]".chartFace = "org.kde.ksysguard.piechart";
      "[Containments][292][Applets][298][Configuration][Appearance]".title     = "Individual Core Usage";
      "[Containments][292][Applets][298][Configuration][ConfigDialog]".DialogHeight = 540;
      "[Containments][292][Applets][298][Configuration][ConfigDialog]".DialogWidth  = 720;
      "[Containments][292][Applets][298][Configuration][Sensors]".highPrioritySensorIds =
        ''["gpu/gpu1/usage","gpu/gpu1/usedVram"]'';
      "[Containments][292][Applets][298][Configuration][Sensors]".totalSensors =
        ''["cpu/all/usage"]'';
      "[Containments][292][Applets][298][Configuration][SensorColors]" = {
        "cpu/cpu.*/usage"  = "149,136,49";
        "cpu/cpu0/usage"   = "149,136,49";
        "cpu/cpu1/usage"   = "125,149,49";
        "cpu/cpu2/usage"   = "87,149,49";
        "cpu/cpu3/usage"   = "50,149,49";
        "cpu/cpu4/usage"   = "49,149,86";
        "cpu/cpu5/usage"   = "49,149,124";
        "cpu/cpu6/usage"   = "49,137,149";
        "cpu/cpu7/usage"   = "49,100,149";
        "cpu/cpu8/usage"   = "49,62,149";
        "cpu/cpu9/usage"   = "74,49,149";
        "cpu/cpu10/usage"  = "111,49,149";
        "cpu/cpu11/usage"  = "149,49,149";
        "cpu/cpu12/usage"  = "149,49,112";
        "cpu/cpu13/usage"  = "149,49,75";
        "cpu/cpu14/usage"  = "149,61,49";
        "cpu/cpu15/usage"  = "149,99,49";
        "gpu/gpu1/usage"   = "49,149,51";
        "gpu/gpu1/usedVram"= "49,149,94";
      };

      # Memory (299)
      "[Containments][292][Applets][299]".plugin = "org.kde.plasma.systemmonitor.memory";
      "[Containments][292][Applets][299][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][292][Applets][299][Configuration][Appearance]".chartFace = "org.kde.ksysguard.piechart";
      "[Containments][292][Applets][299][Configuration][Appearance]".title     = "Memory Usage";
      "[Containments][292][Applets][299][Configuration][SensorColors]"."memory/physical/used" = "149,136,49";
      "[Containments][292][Applets][299][Configuration][Sensors]".highPrioritySensorIds = ''["memory/physical/used"]'';
      "[Containments][292][Applets][299][Configuration][Sensors]".lowPrioritySensorIds  = ''["memory/physical/total"]'';
      "[Containments][292][Applets][299][Configuration][Sensors]".totalSensors          = ''["memory/physical/usedPercent"]'';

      # Separator (300)
      "[Containments][292][Applets][300]".plugin = "org.kde.plasma.marginsseparator";

      # System tray (301) + inner applets
      "[Containments][292][Applets][301]".plugin = "org.kde.plasma.systemtray";
      "[Containments][292][Applets][301][Configuration]".popupHeight = 432;
      "[Containments][292][Applets][301][Configuration]".popupWidth  = 432;
      "[Containments][292][Applets][301][General]".extraItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";
      "[Containments][292][Applets][301][General]".knownItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";
      "[Containments][292][Applets][301][Applets][302]".plugin = "org.kde.plasma.devicenotifier";
      "[Containments][292][Applets][301][Applets][303]".plugin = "org.kde.plasma.clipboard";
      "[Containments][292][Applets][301][Applets][304]".plugin = "org.kde.plasma.manage-inputmethod";
      "[Containments][292][Applets][301][Applets][305]".plugin = "org.kde.plasma.cameraindicator";
      "[Containments][292][Applets][301][Applets][306]".plugin = "org.kde.plasma.notifications";
      "[Containments][292][Applets][301][Applets][307]".plugin = "org.kde.kdeconnect";
      "[Containments][292][Applets][301][Applets][308]".plugin = "org.kde.plasma.keyboardindicator";
      "[Containments][292][Applets][301][Applets][309]".plugin = "org.kde.plasma.keyboardlayout";
      "[Containments][292][Applets][301][Applets][310]".plugin = "org.kde.plasma.weather";
      "[Containments][292][Applets][301][Applets][311]".plugin = "org.kde.plasma.printmanager";
      "[Containments][292][Applets][301][Applets][312]".plugin = "org.kde.plasma.volume";
      "[Containments][292][Applets][301][Applets][312][Configuration][General]".migrated = true;
      "[Containments][292][Applets][301][Applets][313]".plugin = "org.kde.kscreen";
      "[Containments][292][Applets][301][Applets][316]".plugin = "org.kde.plasma.battery";
      "[Containments][292][Applets][301][Applets][317]".plugin = "org.kde.plasma.brightness";
      "[Containments][292][Applets][301][Applets][318]".plugin = "org.kde.plasma.networkmanagement";

      # Digital clock (314)
      "[Containments][292][Applets][314]".plugin = "org.kde.plasma.digitalclock";
      "[Containments][292][Applets][314][Configuration]".popupHeight = 400;
      "[Containments][292][Applets][314][Configuration]".popupWidth  = 560;

      # Show desktop (315)
      "[Containments][292][Applets][315]".plugin = "org.kde.plasma.showdesktop";

      # Screen mapping section kept minimal as in your paste
      "[ScreenMapping]".itemsOnDisabledScreens = "";
    };
  };

  xdg.desktopEntries.vscodium = {
    name        = "VSCodium";
    genericName = "Source-code Editor";
    exec        = "codium %F";
    icon        = "vscodium";
    mimeType    = [ "inode/directory" ];
    categories  = [ "Utility" "Development" "TextEditor" "IDE" ];
    terminal    = false;
  };
  xdg.mimeApps = {
    enable = true;
    associations.added."inode/directory"  = [ "vscodium.desktop" ];
    defaultApplications."inode/directory" = [ "org.kde.dolphin.desktop" ];
  };
}
