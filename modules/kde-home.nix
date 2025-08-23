# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  # Use the same path your pasted config expects (hyphenated folder name)
  wpDir = "${config.home.homeDirectory}/Pictures/desktop-backgrounds";
in {
  programs.plasma = {
    enable = true;

    # Wipe unmanaged KDE configs on activation and write only what's here.
    # (Declarative, reproducible layout.)
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

    # Let appletsrc (below) own the panel/desktop layout to match your paste.
    panels = lib.mkForce [ ];

    # Write the exact KConfig you provided into Plasma’s applet layout.
    # (We only substitute SlidePaths with ${wpDir} so it’s portable.)
    xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc" = lib.mkForce {
    force = true;  # overwrite if the file already exists
    text = ''
          [ActionPlugins][0]
          RightButton;NoModifier=org.kde.contextmenu

          [ActionPlugins][1]
          RightButton;NoModifier=org.kde.contextmenu

          [Containments][94]
          ItemGeometries-3840x2160=
          ItemGeometriesHorizontal=
          activityId=473135d4-494b-44cf-8f77-b3dd0bacedc9
          formfactor=0
          immutability=1
          lastScreen=0
          location=0
          plugin=org.kde.plasma.folder
          wallpaperplugin=org.kde.slideshow

          [Containments][94][ConfigDialog]
          DialogHeight=540
          DialogWidth=720

          [Containments][94][General]
          positions={"3840x2160":[]}

          [Containments][94][Wallpaper][org.kde.slideshow][General]
          SlideInterval=900
          SlidePaths=${wpDir}

          [Containments][98]
          activityId=
          formfactor=2
          immutability=1
          lastScreen[$i]=0
          location=4
          plugin=org.kde.panel
          wallpaperplugin=org.kde.image

          [Containments][98][Applets][100]
          immutability=1
          plugin=org.kde.plasma.pager

          [Containments][98][Applets][101]
          immutability=1
          plugin=org.kde.plasma.icontasks

          [Containments][98][Applets][101][Configuration][General]
          launchers=preferred://browser,preferred://filemanager,applications:org.strawberrymusicplayer.strawberry.desktop

          [Containments][98][Applets][102]
          immutability=1
          plugin=org.kde.plasma.marginsseparator

          [Containments][98][Applets][103]
          activityId=
          formfactor=0
          immutability=1
          lastScreen=-1
          location=0
          plugin=org.kde.plasma.systemtray
          popupHeight=432
          popupWidth=432
          wallpaperplugin=org.kde.image

          [Containments][98][Applets][103][Applets][104]
          immutability=1
          plugin=org.kde.plasma.devicenotifier

          [Containments][98][Applets][103][Applets][105]
          immutability=1
          plugin=org.kde.plasma.clipboard

          [Containments][98][Applets][103][Applets][106]
          immutability=1
          plugin=org.kde.plasma.manage-inputmethod

          [Containments][98][Applets][103][Applets][107]
          immutability=1
          plugin=org.kde.plasma.cameraindicator

          [Containments][98][Applets][103][Applets][108]
          immutability=1
          plugin=org.kde.plasma.notifications

          [Containments][98][Applets][103][Applets][109]
          immutability=1
          plugin=org.kde.kdeconnect

          [Containments][98][Applets][103][Applets][110]
          immutability=1
          plugin=org.kde.plasma.keyboardindicator

          [Containments][98][Applets][103][Applets][111]
          immutability=1
          plugin=org.kde.plasma.keyboardlayout

          [Containments][98][Applets][103][Applets][112]
          immutability=1
          plugin=org.kde.plasma.weather

          [Containments][98][Applets][103][Applets][113]
          immutability=1
          plugin=org.kde.plasma.printmanager

          [Containments][98][Applets][103][Applets][114]
          immutability=1
          plugin=org.kde.plasma.volume

          [Containments][98][Applets][103][Applets][114][Configuration][General]
          migrated=true

          [Containments][98][Applets][103][Applets][115]
          immutability=1
          plugin=org.kde.kscreen

          [Containments][98][Applets][103][Applets][118]
          immutability=1
          plugin=org.kde.plasma.battery

          [Containments][98][Applets][103][Applets][119]
          immutability=1
          plugin=org.kde.plasma.brightness

          [Containments][98][Applets][103][Applets][120]
          immutability=1
          plugin=org.kde.plasma.mediacontroller

          [Containments][98][Applets][103][Applets][121]
          immutability=1
          plugin=org.kde.plasma.networkmanagement

          [Containments][98][Applets][103][General]
          extraItems=org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen
          knownItems=org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.cameraindicator,org.kde.plasma.notifications,org.kde.kdeconnect,org.kde.plasma.brightness,org.kde.plasma.battery,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.printmanager,org.kde.plasma.mediacontroller,org.kde.plasma.volume,org.kde.kscreen

          [Containments][98][Applets][116]
          immutability=1
          plugin=org.kde.plasma.digitalclock

          [Containments][98][Applets][116][Configuration]
          popupHeight=400
          popupWidth=560

          [Containments][98][Applets][116][Configuration][Appearance]
          fontWeight=400

          [Containments][98][Applets][117]
          immutability=1
          plugin=org.kde.plasma.showdesktop

          [Containments][98][Applets][123]
          immutability=1
          plugin=org.kde.plasma.systemmonitor.cpucore

          [Containments][98][Applets][123][Configuration]
          CurrentPreset=org.kde.plasma.systemmonitor
          PreloadWeight=65
          popupHeight=386
          popupWidth=306

          [Containments][98][Applets][123][Configuration][Appearance]
          chartFace=org.kde.ksysguard.barchart
          title=Individual Core Usage

          [Containments][98][Applets][123][Configuration][SensorColors]
          cpu/cpu.*/usage=149,136,49
          cpu/cpu0/usage=149,136,49
          cpu/cpu1/usage=125,149,49
          cpu/cpu10/usage=111,49,149
          cpu/cpu11/usage=149,49,149
          cpu/cpu12/usage=149,49,112
          cpu/cpu13/usage=149,49,75
          cpu/cpu14/usage=149,61,49
          cpu/cpu15/usage=149,99,49
          cpu/cpu2/usage=87,149,49
          cpu/cpu3/usage=50,149,49
          cpu/cpu4/usage=49,149,86
          cpu/cpu5/usage=49,149,124
          cpu/cpu6/usage=49,137,149
          cpu/cpu7/usage=49,100,149
          cpu/cpu8/usage=49,62,149
          cpu/cpu9/usage=74,49,149

          [Containments][98][Applets][123][Configuration][Sensors]
          highPrioritySensorIds=["cpu/cpu.*/usage"]
          totalSensors=["cpu/all/usage"]

          [Containments][98][Applets][124]
          immutability=1
          plugin=org.kde.plasma.systemmonitor.cpucore

          [Containments][98][Applets][124][Configuration]
          CurrentPreset=org.kde.plasma.systemmonitor
          PreloadWeight=100
          popupHeight=306
          popupWidth=271

          [Containments][98][Applets][124][Configuration][Appearance]
          chartFace=org.kde.ksysguard.piechart
          title=Individual GPU Core Usage

          [Containments][98][Applets][124][Configuration][ConfigDialog]
          DialogHeight=540
          DialogWidth=720

          [Containments][98][Applets][124][Configuration][FaceGrid][Appearance]
          chartFace=org.kde.ksysguard.linechart
          showTitle=false

          [Containments][98][Applets][124][Configuration][FaceGrid][SensorColors]
          gpu/gpu1/totalVram=149,49,136
          gpu/gpu1/usage=170,0,255
          gpu/gpu1/usedVram=0,85,255
          gpu/gpu\\d+/totalVram=49,138,149
          gpu/gpu\\d+/usage=62,49,149
          gpu/gpu\\d+/usedVram=141,149,49

          [Containments][98][Applets][124][Configuration][FaceGrid][Sensors]
          highPrioritySensorIds=["gpu/gpu1/usage"]

          [Containments][98][Applets][124][Configuration][SensorColors]
          gpu/gpu1/coreFrequency=49,98,149
          gpu/gpu1/fan1=149,61,49
          gpu/gpu1/temperature=93,149,49
          gpu/gpu1/totalVram=149,49,136
          gpu/gpu1/usage=170,0,255
          gpu/gpu1/usedVram=85,255,255
          gpu/gpu\\d+/totalVram=49,138,149
          gpu/gpu\\d+/usage=62,49,149
          gpu/gpu\\d+/usedVram=141,149,49

          [Containments][98][Applets][124][Configuration][Sensors]
          highPrioritySensorIds=["gpu/gpu1/usedVram","gpu/gpu1/usage","gpu/gpu1/coreFrequency","gpu/gpu1/fan1","gpu/gpu1/temperature"]
          totalSensors=["cpu/all/usage"]

          [Containments][98][Applets][125]
          immutability=1
          plugin=org.kde.plasma.systemmonitor.memory

          [Containments][98][Applets][125][Configuration]
          CurrentPreset=org.kde.plasma.systemmonitor
          PreloadWeight=95
          popupHeight=240
          popupWidth=244

          [Containments][98][Applets][125][Configuration][Appearance]
          chartFace=org.kde.ksysguard.piechart
          title=Memory Usage

          [Containments][98][Applets][125][Configuration][ConfigDialog]
          DialogHeight=540
          DialogWidth=720

          [Containments][98][Applets][125][Configuration][SensorColors]
          memory/physical/used=0,0,255

          [Containments][98][Applets][125][Configuration][Sensors]
          highPrioritySensorIds=["memory/physical/used"]
          lowPrioritySensorIds=["memory/physical/total"]
          totalSensors=["memory/physical/usedPercent"]

          [Containments][98][Applets][126]
          immutability=1
          plugin=org.kde.plasma.systemmonitor.net

          [Containments][98][Applets][126][Configuration]
          CurrentPreset=org.kde.plasma.systemmonitor
          PreloadWeight=90
          popupHeight=200
          popupWidth=210

          [Containments][98][Applets][126][Configuration][Appearance]
          chartFace=org.kde.ksysguard.linechart
          title=Network Speed

          [Containments][98][Applets][126][Configuration][ConfigDialog]
          DialogHeight=540
          DialogWidth=720

          [Containments][98][Applets][126][Configuration][SensorColors]
          network/all/download=0,255,255
          network/all/upload=170,0,255

          [Containments][98][Applets][126][Configuration][Sensors]
          highPrioritySensorIds=["network/all/download","network/all/upload"]

          [Containments][98][Applets][99]
          immutability=1
          plugin=org.kde.plasma.kickoff

          [Containments][98][Applets][99][Configuration]
          PreloadWeight=100
          popupHeight=508
          popupWidth=647

          [Containments][98][Applets][99][Configuration][General]
          favoritesPortedToKAstats=true
          icon=distributor-logo-steamdeck

          [Containments][98][General]
          AppletOrder=99;100;101;126;123;124;125;102;103;116;117

          [ScreenMapping]
          itemsOnDisabledScreens=
          screenMapping=
    '';
    };
  };

  # VSCodium desktop entry override (kept from your base module)
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
