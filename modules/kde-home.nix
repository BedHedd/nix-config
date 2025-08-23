# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  wpDir = "${config.home.homeDirectory}/Pictures/desktop backgrounds";
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

    # Panel layout (widgets order matches your AppletOrder)
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";
        widgets = [
          "org.kde.plasma.kickoff"                 # 99
          "org.kde.plasma.pager"                   # 100
          "org.kde.plasma.icontasks"               # 101
          "org.kde.plasma.systemmonitor.net"       # 126
          "org.kde.plasma.systemmonitor.cpucore"   # 123
          "org.kde.plasma.systemmonitor.cpucore"   # 124 (used for GPU)
          "org.kde.plasma.systemmonitor.memory"    # 125
          "org.kde.plasma.marginsseparator"        # 102
          "org.kde.plasma.systemtray"              # 103
          "org.kde.plasma.digitalclock"            # 116
          "org.kde.plasma.showdesktop"             # 117
        ];
      }
    ];

    # Exact KConfig you pasted (sections/keys mapped verbatim)
    configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
      # Context menu on right click
      "[ActionPlugins][0]"."RightButton;NoModifier" = "org.kde.contextmenu";
      "[ActionPlugins][1]"."RightButton;NoModifier" = "org.kde.contextmenu";

      # Desktop containment (94) — slideshow, positions, etc.
      "[Containments][94]".formfactor     = 0;
      "[Containments][94]".immutability   = 1;
      "[Containments][94]".lastScreen     = 0;
      "[Containments][94]".location       = 0;
      "[Containments][94]".plugin         = "org.kde.plasma.folder";
      "[Containments][94]".wallpaperplugin = "org.kde.slideshow";
      "[Containments][94][ConfigDialog]".DialogHeight = 540;
      "[Containments][94][ConfigDialog]".DialogWidth  = 720;
      "[Containments][94][General]".positions = ''{"3840x2160":[]}'';
      "[Containments][94][Wallpaper][org.kde.slideshow][General]".SlideInterval = 900;
      "[Containments][94][Wallpaper][org.kde.slideshow][General]".SlidePaths    = wpDir;

      # Panel containment (98)
      "[Containments][98]".formfactor   = 2;
      "[Containments][98]".immutability = 1;
      "[Containments][98]".lastScreen   = 0;
      "[Containments][98]".location     = 4;
      "[Containments][98]".plugin       = "org.kde.panel";
      "[Containments][98]".wallpaperplugin = "org.kde.image";
      "[Containments][98][General]".AppletOrder =
        "99;100;101;126;123;124;125;102;103;116;117";

      # Kickoff (99)
      "[Containments][98][Applets][99]".plugin = "org.kde.plasma.kickoff";
      "[Containments][98][Applets][99][Configuration]".PreloadWeight = 100;
      "[Containments][98][Applets][99][Configuration]".popupHeight   = 508;
      "[Containments][98][Applets][99][Configuration]".popupWidth    = 647;
      "[Containments][98][Applets][99][Configuration][General]".icon =
        "distributor-logo-steamdeck";

      # Pager (100)
      "[Containments][98][Applets][100]".plugin = "org.kde.plasma.pager";

      # Icon Tasks (101)
      "[Containments][98][Applets][101]".plugin = "org.kde.plasma.icontasks";
      "[Containments][98][Applets][101][Configuration][General]".launchers =
        "preferred://browser,preferred://filemanager,applications:org.strawberrymusicplayer.strawberry.desktop";

      # Margins separator (102)
      "[Containments][98][Applets][102]".plugin = "org.kde.plasma.marginsseparator";

      # System tray (103) + inner applets
      "[Containments][98][Applets][103]".plugin = "org.kde.plasma.systemtray";
      "[Containments][98][Applets][103][Configuration]".popupHeight = 432;
      "[Containments][98][Applets][103][Configuration]".popupWidth  = 432;
      "[Containments][98][Applets][103][General]".extraItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";
      "[Containments][98][Applets][103][General]".knownItems =
        "org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen";

      # Inner system tray applets (plugins)
      "[Containments][98][Applets][103][Applets][104]".plugin = "org.kde.plasma.devicenotifier";
      "[Containments][98][Applets][103][Applets][105]".plugin = "org.kde.plasma.clipboard";
      "[Containments][98][Applets][103][Applets][106]".plugin = "org.kde.plasma.manage-inputmethod";
      "[Containments][98][Applets][103][Applets][107]".plugin = "org.kde.plasma.cameraindicator";
      "[Containments][98][Applets][103][Applets][108]".plugin = "org.kde.plasma.notifications";
      "[Containments][98][Applets][103][Applets][109]".plugin = "org.kde.kdeconnect";
      "[Containments][98][Applets][103][Applets][110]".plugin = "org.kde.plasma.keyboardindicator";
      "[Containments][98][Applets][103][Applets][111]".plugin = "org.kde.plasma.keyboardlayout";
      "[Containments][98][Applets][103][Applets][112]".plugin = "org.kde.plasma.weather";
      "[Containments][98][Applets][103][Applets][113]".plugin = "org.kde.plasma.printmanager";
      "[Containments][98][Applets][103][Applets][114]".plugin = "org.kde.plasma.volume";
      "[Containments][98][Applets][103][Applets][114][Configuration][General]".migrated = true;
      "[Containments][98][Applets][103][Applets][115]".plugin = "org.kde.kscreen";
      "[Containments][98][Applets][103][Applets][118]".plugin = "org.kde.plasma.battery";
      "[Containments][98][Applets][103][Applets][119]".plugin = "org.kde.plasma.brightness";
      "[Containments][98][Applets][103][Applets][120]".plugin = "org.kde.plasma.mediacontroller";
      "[Containments][98][Applets][103][Applets][121]".plugin = "org.kde.plasma.networkmanagement";

      # Digital clock (116)
      "[Containments][98][Applets][116]".plugin = "org.kde.plasma.digitalclock";
      "[Containments][98][Applets][116][Configuration]".popupHeight = 400;
      "[Containments][98][Applets][116][Configuration]".popupWidth  = 560;
      "[Containments][98][Applets][116][Configuration][Appearance]".fontWeight = 400;

      # Show desktop (117)
      "[Containments][98][Applets][117]".plugin = "org.kde.plasma.showdesktop";

      # System Monitor: CPU cores (123)
      "[Containments][98][Applets][123]".plugin = "org.kde.plasma.systemmonitor.cpucore";
      "[Containments][98][Applets][123][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][98][Applets][123][Configuration]".PreloadWeight = 65;
      "[Containments][98][Applets][123][Configuration]".popupHeight   = 386;
      "[Containments][98][Applets][123][Configuration]".popupWidth    = 306;
      "[Containments][98][Applets][123][Configuration][Appearance]".chartFace = "org.kde.ksysguard.barchart";
      "[Containments][98][Applets][123][Configuration][Appearance]".title     = "Individual Core Usage";
      "[Containments][98][Applets][123][Configuration][Sensors]".highPrioritySensorIds = ''["cpu/cpu.*/usage"]'';
      "[Containments][98][Applets][123][Configuration][Sensors]".totalSensors         = ''["cpu/all/usage"]'';
      # Individual CPU colors
      "[Containments][98][Applets][123][Configuration][SensorColors]" = {
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

      # System Monitor: “GPU cores” (124) — using GPU signals
      "[Containments][98][Applets][124]".plugin = "org.kde.plasma.systemmonitor.cpucore";
      "[Containments][98][Applets][124][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][98][Applets][124][Configuration]".PreloadWeight = 100;
      "[Containments][98][Applets][124][Configuration]".popupHeight   = 306;
      "[Containments][98][Applets][124][Configuration]".popupWidth    = 271;
      "[Containments][98][Applets][124][Configuration][Appearance]".chartFace = "org.kde.ksysguard.piechart";
      "[Containments][98][Applets][124][Configuration][Appearance]".title     = "Individual GPU Core Usage";
      "[Containments][98][Applets][124][Configuration][ConfigDialog]".DialogHeight = 540;
      "[Containments][98][Applets][124][Configuration][ConfigDialog]".DialogWidth  = 720;
      "[Containments][98][Applets][124][Configuration][FaceGrid][Appearance]".chartFace = "org.kde.ksysguard.linechart";
      "[Containments][98][Applets][124][Configuration][FaceGrid][Appearance]".showTitle = false;
      "[Containments][98][Applets][124][Configuration][FaceGrid][Sensors]".highPrioritySensorIds =
        ''["gpu/2/usage"]'';
      "[Containments][98][Applets][124][Configuration][Sensors]".highPrioritySensorIds =
        ''["gpu/2/usedVram","gpu/2/usage","gpu/2/coreFrequency","gpu/2/fan1","gpu/2/temperature"]'';
      "[Containments][98][Applets][124][Configuration][Sensors]".totalSensors =
        ''["cpu/all/usage"]'';
      "[Containments][98][Applets][124][Configuration][SensorColors]" = {
        "gpu/2/coreFrequency" = "49,98,149";
        "gpu/2/fan1"          = "149,61,49";
        "gpu/2/temperature"   = "93,149,49";
        "gpu/2/totalVram"     = "149,49,136";
        "gpu/2/usage"         = "170,0,255";
        "gpu/2/usedVram"      = "85,255,255";
        "gpu/gpu\\d+/totalVram"  = "49,138,149";
        "gpu/gpu\\d+/usage"      = "62,49,149";
        "gpu/gpu\\d+/usedVram"   = "141,149,49";
      };
      "[Containments][98][Applets][124][Configuration][FaceGrid][SensorColors]" = {
        "gpu/2/totalVram"    = "149,49,136";
        "gpu/2/usage"        = "170,0,255";
        "gpu/2/usedVram"     = "0,85,255";
        "gpu/gpu\\d+/totalVram" = "49,138,149";
        "gpu/gpu\\d+/usage"     = "62,49,149";
        "gpu/gpu\\d+/usedVram"  = "141,149,49";
      };

      # System Monitor: Memory (125)
      "[Containments][98][Applets][125]".plugin = "org.kde.plasma.systemmonitor.memory";
      "[Containments][98][Applets][125][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][98][Applets][125][Configuration]".PreloadWeight = 95;
      "[Containments][98][Applets][125][Configuration]".popupHeight   = 240;
      "[Containments][98][Applets][125][Configuration]".popupWidth    = 244;
      "[Containments][98][Applets][125][Configuration][Appearance]".chartFace = "org.kde.ksysguard.piechart";
      "[Containments][98][Applets][125][Configuration][Appearance]".title     = "Memory Usage";
      "[Containments][98][Applets][125][Configuration][ConfigDialog]".DialogHeight = 540;
      "[Containments][98][Applets][125][Configuration][ConfigDialog]".DialogWidth  = 720;
      "[Containments][98][Applets][125][Configuration][SensorColors]"."memory/physical/used" = "0,0,255";
      "[Containments][98][Applets][125][Configuration][Sensors]".highPrioritySensorIds = ''["memory/physical/used"]'';
      "[Containments][98][Applets][125][Configuration][Sensors]".lowPrioritySensorIds  = ''["memory/physical/total"]'';
      "[Containments][98][Applets][125][Configuration][Sensors]".totalSensors          = ''["memory/physical/usedPercent"]'';

      # System Monitor: Network (126)
      "[Containments][98][Applets][126]".plugin = "org.kde.plasma.systemmonitor.net";
      "[Containments][98][Applets][126][Configuration]".CurrentPreset = "org.kde.plasma.systemmonitor";
      "[Containments][98][Applets][126][Configuration]".PreloadWeight = 90;
      "[Containments][98][Applets][126][Configuration]".popupHeight   = 200;
      "[Containments][98][Applets][126][Configuration]".popupWidth    = 210;
      "[Containments][98][Applets][126][Configuration][Appearance]".chartFace = "org.kde.ksysguard.linechart";
      "[Containments][98][Applets][126][Configuration][Appearance]".title     = "Network Speed";
      "[Containments][98][Applets][126][Configuration][ConfigDialog]".DialogHeight = 540;
      "[Containments][98][Applets][126][Configuration][ConfigDialog]".DialogWidth  = 720;
      "[Containments][98][Applets][126][Configuration][SensorColors]"."network/all/download" = "0,255,255";
      "[Containments][98][Applets][126][Configuration][SensorColors]"."network/all/upload"   = "170,0,255";
      "[Containments][98][Applets][126][Configuration][Sensors]".highPrioritySensorIds =
        ''["network/all/download","network/all/upload"]'';
    };
  };

  # (kept from your skeleton) VSCodium desktop entry + MIME bindings
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
