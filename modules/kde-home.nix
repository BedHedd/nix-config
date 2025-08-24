# modules/kde-home.nix
{ config, lib, pkgs, plasma-manager, ... }:
let
  wpDir        = "${config.home.homeDirectory}/Pictures/desktop backgrounds";
  intervalS    = 900; # seconds between wallpaper changes (sync cadence)

  # Script: pick frame deterministically and set same image on ALL desktops
  syncWallpapers = pkgs.writeShellScriptBin "sync-wallpapers" ''
    set -euo pipefail
    DIR=${lib.escapeShellArg wpDir}
    INTERVAL=${toString intervalS}

    # Collect images (stable order)
    mapfile -t FILES < <(${pkgs.findutils}/bin/find "$DIR" -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      | ${pkgs.coreutils}/bin/sort)

    [ "''${#FILES[@]}" -gt 0 ] || exit 0

    now=$(${pkgs.coreutils}/bin/date +%s)
    idx=$(( (now / INTERVAL) % ''${#FILES[@]} ))
    img="''${FILES[$idx]}"

    # Plasma JS: set same static image on every desktop
    js='var ds = desktops();
        for (var i = 0; i < ds.length; ++i) {
          var d = ds[i];
          d.wallpaperPlugin = "org.kde.image";
          d.currentConfigGroup = ["Wallpaper","org.kde.image","General"];
          d.writeConfig("Image", "file://'"$img"'" );
        }'
    ${pkgs.qt6.qttools}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js"
  '';
in {
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "com.valve.vgui.desktop";

    # IMPORTANT: Do NOT use Plasma's slideshow for the desktop; our timer drives it.
    # Provide any static fallback image; the timer will immediately override it at login.
    workspace.wallpaper =
      "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1920x1080.jpg";
    
    # Desktop & lock screen slideshows — 15 minutes
    # workspace.wallpaperSlideShow = { # uncomment this block if you want to use the native slideshow, but wallpapers won't be synced
    #   path     = wpDir;
    #   interval = 900;
    #   randomize = true;
    #   fillMode  = "zoom";     
    # };

    # Lock screen can keep using slideshow (independent of desktop sync)
    kscreenlocker.appearance.wallpaperSlideShow = {
      path     = wpDir;
      interval = intervalS;
    };

    shortcuts = {
      kwin = {
        # Keep only Alt+` and drop Meta+`
        "Walk Through Windows of Current Application" = [ "Alt+`" ];
        "Walk Through Windows of Current Application (Reverse)" = [ "Alt+~" ];

        # If these “Alternative” bindings exist on your system,
        # clearing them ensures Super/Meta isn't grabbed anywhere:
        "Walk Through Windows Alternative" = [ ];
        "Walk Through Windows Alternative (Reverse)" = [ ];
        };
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

    # Panel layout (unchanged)
    panels = lib.mkForce [
      {
        screen   = "all";
        location = "bottom";
        height   = 64;
        floating = false;
        hiding   = "dodgewindows";

        widgets = [
          # Kickoff
          {
            name = "org.kde.plasma.kickoff";
            config = {
              PreloadWeight   = 100;
              popupHeight     = 508;
              popupWidth      = 647;
              "General/icon"  = "distributor-logo-steamdeck";
            };
          }

          # Pager
          "org.kde.plasma.pager"

          # Icon Tasks
          {
            name = "org.kde.plasma.icontasks";
            config = {
              "launchers" = [
                "preferred://browser"
                "preferred://filemanager"
                "applications:org.strawberrymusicplayer.strawberry.desktop"
                "applications:steam.desktop"
              ];

              "General/sortingStrategy"   = 0;
              "General/separateLaunchers" = true;
            };
          }

          # System Monitor: Network
          {
            name = "org.kde.plasma.systemmonitor.net";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 90;
              popupHeight   = 200;
              popupWidth    = 210;

              "Appearance/chartFace" = "org.kde.ksysguard.linechart";
              "Appearance/title"     = "Network Speed";

              "Sensors/highPrioritySensorIds" = [
                "network/all/download"
                "network/all/upload"
              ];

              "SensorColors/network/all/download" = "0,255,255";
              "SensorColors/network/all/upload"   = "170,0,255";
            };
          }

          # System Monitor: CPU cores
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 65;
              popupHeight   = 386;
              popupWidth    = 306;

              "Appearance/chartFace" = "org.kde.ksysguard.barchart";
              "Appearance/title"     = "Individual Core Usage";

              "Sensors/highPrioritySensorIds" = [ "cpu/cpu.*/usage" ];
              "Sensors/totalSensors"          = [ "cpu/all/usage" ];
            };
          }

          # System Monitor: Memory
          {
            name = "org.kde.plasma.systemmonitor.memory";
            config = {
              CurrentPreset = "org.kde.plasma.systemmonitor";
              PreloadWeight = 95;
              popupHeight   = 240;
              popupWidth    = 244;

              "Appearance/chartFace" = "org.kde.ksysguard.piechart";
              "Appearance/title"     = "Memory Usage";

              "Sensors/highPrioritySensorIds" = [ "memory/physical/used" ];
              "Sensors/lowPrioritySensorIds"  = [ "memory/physical/total" ];
              "Sensors/totalSensors"          = [ "memory/physical/usedPercent" ];

              "SensorColors/memory/physical/used" = "0,0,255";
            };
          }

          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"

          {
            name = "org.kde.plasma.digitalclock";
            config = {
              popupHeight = 400;
              popupWidth  = 560;
              "Appearance/fontWeight" = 400;
            };
          }

          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # Run once at login so you start in sync immediately (after Plasma init)
    startup.desktopScript."sync-wallpapers-on-login" = {
      text = ''"${syncWallpapers}/bin/sync-wallpapers"'';
      priority = 3; # after other Plasma startup scripts
    };
  };

  # Timer/service to update every intervalS seconds (keeps all monitors in lockstep)
  systemd.user.services.sync-wallpapers = {
    Unit.Description = "Sync KDE wallpapers across monitors";
    Service = {
      Type = "oneshot";
      ExecStart = "${syncWallpapers}/bin/sync-wallpapers";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.sync-wallpapers = {
    Unit.Description = "Timer for synced wallpapers";
    Timer = {
      OnBootSec = "7s";
      OnUnitActiveSec = "${toString intervalS}s";
      AccuracySec = "1s";
    };
    Install.WantedBy = [ "timers.target" ];
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
