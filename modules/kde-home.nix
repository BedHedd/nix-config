# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  # Uses your folder with a space in the name
  wpDir    = "${config.home.homeDirectory}/Pictures/desktop backgrounds";
  imageUri = "file://${wpDir}/739453.png";
in {
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "com.valve.vgui.desktop";

    # Desktop & lock screen slideshows — 15 minutes
    workspace.wallpaperSlideShow = { path = wpDir; interval = 900; };
    kscreenlocker.appearance.wallpaperSlideShow = { path = wpDir; interval = 900; };

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

    # Panel layout in the exact AppletOrder you provided
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";
        widgets = [
          "org.kde.plasma.kickoff"               # 347
          "org.kde.plasma.pager"                 # 348
          "org.kde.plasma.icontasks"             # 349
          "org.kde.plasma.systemmonitor.net"     # 350
          "org.kde.plasma.systemmonitor.cpucore" # 351
          "org.kde.plasma.systemmonitor.memory"  # 353
          "org.kde.plasma.marginsseparator"      # 354
          "org.kde.plasma.systemtray"            # 355
          "org.kde.plasma.digitalclock"          # 368
          "org.kde.plasma.showdesktop"           # 369
        ];
      }
    ];

    # Verbatim KConfig mapped to your latest snippet
    configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
      # Actions
      "[Containments][346][Applets][349][Configuration][General]" = {
        sortingStrategy   = 0;   # 0 = Manual
        separateLaunchers = true;
        launchers =
          "preferred://browser,preferred://filemanager,applications:org.strawberrymusicplayer.strawberry.desktop";
      };
      
      "[ActionPlugins][0]"."MiddleButton;NoModifier" = "org.kde.paste";
      "[ActionPlugins][0]"."RightButton;NoModifier"  = "org.kde.contextmenu";
      "[ActionPlugins][1]"."RightButton;NoModifier"  = "org.kde.contextmenu";

      # Desktop containment (343)
      "[Containments][343]"."ItemGeometries-3840x2160" = "";
      "[Containments][343]".ItemGeometriesHorizontal   = "";
      "[Containments][343]".activityId     = "ed620766-7e82-40af-9264-098ccf25843c";
      "[Containments][343]".formfactor     = 0;
      "[Containments][343]".immutability   = 1;
      "[Containments][343]".lastScreen     = 0;
      "[Containments][343]".location       = 0;
      "[Containments][343]".plugin         = "org.kde.plasma.folder";
      "[Containments][343]".wallpaperplugin = "org.kde.slideshow";
      "[Containments][343][General]".positions = ''{"3840x2160":[]}'';
      "[Containments][343][Wallpaper][org.kde.slideshow][General]".Image         = imageUri;
      "[Containments][343][Wallpaper][org.kde.slideshow][General]".SlideInterval = 900;
      "[Containments][343][Wallpaper][org.kde.slideshow][General]".SlidePaths    = wpDir;

      # Panel containment (346)
      "[Containments][346]".activityId   = "";
      "[Containments][346]".formfactor   = 2;
      "[Containments][346]".immutability = 1;
      "[Containments][346]"."lastScreen[$i]" = 0;
      "[Containments][346]".location     = 4;
      "[Containments][346]".plugin       = "org.kde.panel";
      "[Containments][346]".wallpaperplugin = "org.kde.image";
      "[Containments][346][General]".AppletOrder =
        "347;348;349;350;351;353;354;355;368;369";

      # Kickoff (347)
      "[Containments][346][Applets][347]".plugin = "org.kde.plasma.kickoff";
      "[Containments][346][Applets][347][Configuration]".popupHeight = 400;
      "[Containments][346][Applets][347][Configuration]".popupWidth  = 560;
      "[Containments][346][Applets][347][Configuration][General]".favoritesPortedToKAstats = true;
      "[Containments][346][Applets][347][Configuration][General]".icon = "distributor-logo-steamdeck";

      # Pager (348)
      "[Containments][346][Applets][348]".plugin = "org.kde.plasma.pager";

      # Icon Tasks (349)
      "[Containments][346][Applets][349]".plugin = "org.kde.plasma.icontasks";

      # System Monitor: Network (350)
      "[Containments][346][Applets][350]".plugin = "org.kde.plasma.systemmonitor.net";
      "[Containments][346][Applets][350][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][346][Applets][350][Configuration]".PreloadWeight = 55;
      "[Containments][346][Applets][350][Configuration]".popupHeight   = 200;
      "[Containments][346][Applets][350][Configuration]".popupWidth    = 210;
      "[Containments][346][Applets][350][Configuration][Appearance]".chartFace = "org.kde.ksysguard.linechart";
      "[Containments][346][Applets][350][Configuration][Appearance]".title     = "Network Speed";
      "[Containments][346][Applets][350][Configuration][SensorColors]"."network/all/download" = "149,136,49";
      "[Containments][346][Applets][350][Configuration][SensorColors]"."network/all/upload"   = "49,62,149";
      "[Containments][346][Applets][350][Configuration][Sensors]".highPrioritySensorIds =
        ''["network/all/download","network/all/upload"]'';

      # System Monitor: CPU cores (351)
      "[Containments][346][Applets][351]".plugin = "org.kde.plasma.systemmonitor.cpucore";
      "[Containments][346][Applets][351][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][346][Applets][351][Configuration]".PreloadWeight = 55;
      "[Containments][346][Applets][351][Configuration]".popupHeight   = 386;
      "[Containments][346][Applets][351][Configuration]".popupWidth    = 306;
      "[Containments][346][Applets][351][Configuration][Appearance]".chartFace = "org.kde.ksysguard.barchart";
      "[Containments][346][Applets][351][Configuration][Appearance]".title     = "Individual Core Usage";
      "[Containments][346][Applets][351][Configuration][Sensors]".highPrioritySensorIds = ''["cpu/cpu.*/usage"]'';
      "[Containments][346][Applets][351][Configuration][Sensors]".totalSensors         = ''["cpu/all/usage"]'';
      "[Containments][346][Applets][351][Configuration][SensorColors]" = {
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

      # Memory (353)
      "[Containments][346][Applets][353]".plugin = "org.kde.plasma.systemmonitor.memory";
      "[Containments][346][Applets][353][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][346][Applets][353][Configuration][Appearance]".chartFace = "org.kde.ksysguard.piechart";
      "[Containments][346][Applets][353][Configuration][Appearance]".title     = "Memory Usage";
      "[Containments][346][Applets][353][Configuration][SensorColors]"."memory/physical/used" = "149,136,49";
      "[Containments][346][Applets][353][Configuration][Sensors]".highPrioritySensorIds = ''["memory/physical/used"]'';
      "[Containments][346][Applets][353][Configuration][Sensors]".lowPrioritySensorIds  = ''["memory/physical/total"]'';
      "[Containments][346][Applets][353][Configuration][Sensors]".totalSensors          = ''["memory/physical/usedPercent"]'';

      # Separator (354)
      "[Containments][346][Applets][354]".plugin = "org.kde.plasma.marginsseparator";

      # System tray (355) + inner applets
      "[Containments][346][Applets][355]".plugin = "org.kde.plasma.systemtray";
      "[Containments][346][Applets][355][Configuration]".popupHeight = 432;
      "[Containments][346][Applets][355][Configuration]".popupWidth  = 432;
      "[Containments][346][Applets][355][General]".extraItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";
      "[Containments][346][Applets][355][General]".knownItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";
      "[Containments][346][Applets][355][Applets][356]".plugin = "org.kde.plasma.devicenotifier";
      "[Containments][346][Applets][355][Applets][357]".plugin = "org.kde.plasma.clipboard";
      "[Containments][346][Applets][355][Applets][358]".plugin = "org.kde.plasma.manage-inputmethod";
      "[Containments][346][Applets][355][Applets][359]".plugin = "org.kde.plasma.cameraindicator";
      "[Containments][346][Applets][355][Applets][360]".plugin = "org.kde.plasma.notifications";
      "[Containments][346][Applets][355][Applets][361]".plugin = "org.kde.kdeconnect";
      "[Containments][346][Applets][355][Applets][362]".plugin = "org.kde.plasma.keyboardindicator";
      "[Containments][346][Applets][355][Applets][363]".plugin = "org.kde.plasma.keyboardlayout";
      "[Containments][346][Applets][355][Applets][364]".plugin = "org.kde.plasma.weather";
      "[Containments][346][Applets][355][Applets][365]".plugin = "org.kde.plasma.printmanager";
      "[Containments][346][Applets][355][Applets][366]".plugin = "org.kde.plasma.volume";
      "[Containments][346][Applets][355][Applets][366][Configuration][General]".migrated = true;
      "[Containments][346][Applets][355][Applets][367]".plugin = "org.kde.kscreen";
      "[Containments][346][Applets][355][Applets][370]".plugin = "org.kde.plasma.battery";
      "[Containments][346][Applets][355][Applets][371]".plugin = "org.kde.plasma.brightness";
      "[Containments][346][Applets][355][Applets][372]".plugin = "org.kde.plasma.networkmanagement";

      # Digital clock (368)
      "[Containments][346][Applets][368]".plugin = "org.kde.plasma.digitalclock";
      "[Containments][346][Applets][368][Configuration]".popupHeight = 400;
      "[Containments][346][Applets][368][Configuration]".popupWidth  = 560;

      # Show desktop (369)
      "[Containments][346][Applets][369]".plugin = "org.kde.plasma.showdesktop";

      # Screen mapping
      "[ScreenMapping]".itemsOnDisabledScreens = "";
    };
  };

  # (unchanged) VSCodium entry + MIME bindings
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
