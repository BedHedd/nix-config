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
      temperature.night = 1800;
      transitionTime    = 30;
    };

    # Panel cloned from your appletsrc (Containment 98)
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";

        widgets = [
          # Kickoff (99)
          {
            name = "org.kde.plasma.kickoff";
            config = {
              PreloadWeight = 100;
              popupHeight   = 508;
              popupWidth    = 647;
              General.icon  = "distributor-logo-steamdeck";
            };
          }

          # Pager (100)
          "org.kde.plasma.pager"

          # Icon Tasks (101)
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "preferred://browser"
                "preferred://filemanager"
                "applications:org.strawberrymusicplayer.strawberry.desktop"
              ];
            };
          }

          # System Monitor: Network (126)
          {
            name = "org.kde.plasma.systemmonitor.net";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 90;
              popupHeight   = 200;
              popupWidth    = 210;

              # Face + title
              "org.kde.ksysguard.linechart/General" = {
                title     = "Network Speed";
                chartFace = "org.kde.ksysguard.linechart";
              };

              # Sensors
              Sensors.highPrioritySensorIds = [
                "network/all/download"
                "network/all/upload"
              ];

              # Per-sensor colors
              SensorColors."network/all/download" = "0,255,255";
              SensorColors."network/all/upload"   = "170,0,255";
            };
          }

          # System Monitor: CPU cores (123)
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 65;
              popupHeight   = 386;
              popupWidth    = 306;

              "org.kde.ksysguard.barchart/General" = {
                title     = "Individual Core Usage";
                chartFace = "org.kde.ksysguard.barchart";
              };

              Sensors = {
                highPrioritySensorIds = [ "cpu/cpu.*/usage" ];
                totalSensors          = [ "cpu/all/usage" ];
              };
            };
          }

          # System Monitor: GPU “cores” (124)
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 100;
              popupHeight   = 306;
              popupWidth    = 271;

              "org.kde.ksysguard.piechart/General" = {
                title     = "Individual GPU Core Usage";
                chartFace = "org.kde.ksysguard.piechart";
              };

              # Grid face inside popup
              FaceGrid = {
                "org.kde.ksysguard.linechart/General" = {
                  chartFace = "org.kde.ksysguard.linechart";
                  showTitle = false;
                };
                Sensors.highPrioritySensorIds = [ "gpu/gpu1/usage" ];
              };

              Sensors = {
                highPrioritySensorIds = [
                  "gpu/gpu1/usedVram"
                  "gpu/gpu1/usage"
                  "gpu/gpu1/coreFrequency"
                  "gpu/gpu1/fan1"
                  "gpu/gpu1/temperature"
                ];
                totalSensors = [ "cpu/all/usage" ];
              };
            };
          }

          # System Monitor: Memory (125)
          {
            name = "org.kde.plasma.systemmonitor.memory";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 95;
              popupHeight   = 240;
              popupWidth    = 244;

              "org.kde.ksysguard.piechart/General" = {
                title     = "Memory Usage";
                chartFace = "org.kde.ksysguard.piechart";
              };

              Sensors = {
                highPrioritySensorIds = [ "memory/physical/used" ];
                lowPrioritySensorIds  = [ "memory/physical/total" ];
                totalSensors          = [ "memory/physical/usedPercent" ];
              };

              SensorColors."memory/physical/used" = "0,0,255";
            };
          }

          # Separator (102)
          "org.kde.plasma.marginsseparator"

          # System Tray (103)
          "org.kde.plasma.systemtray"

          # Digital Clock (116)
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              popupHeight = 400;
              popupWidth  = 560;
              Appearance.fontWeight = 400;
            };
          }

          # Show Desktop (117)
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
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
