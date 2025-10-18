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

  # Read your repo JSON, normalize to a single-line JSON string
  kzLayouts = builtins.toJSON (builtins.fromJSON (builtins.readFile ../dotfiles/xiphergrid2_kzones.json));
in {
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "com.valve.vgui.desktop";

    # IMPORTANT: Do NOT use Plasma's slideshow for the desktop; our timer drives it.
    workspace.wallpaper =
      "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1920x1080.jpg";

    # Lock screen can keep using slideshow (independent of desktop sync)
    kscreenlocker.appearance.wallpaperSlideShow = {
      path     = wpDir;
      interval = intervalS;
    };

    # -------------------------
    # KWin + KZones configuration
    # -------------------------
    configFile = {
      # Enable the KZones plugin ONCE (avoid duplicates elsewhere)
      "kwinrc"."Plugins"."kzonesEnabled".value = true;

      # KZones script settings
      "kwinrc"."Script-kzones" = {
        # Supply your layout JSON to both keys seen in your config
        "layouts".value     = kzLayouts;
        "layoutsJson".value = kzLayouts;

        # Match your UI settings / dump
        # 1 == "Only target zone"
        "zoneOverlayIndicatorDisplay".value = 1;

        # Toggles reflected from your screenshot
        "enableZoneSelector".value           = false;
        "selectorTriggerDistance".value      = "Medium";

        "enableZoneOverlay".value            = true;
        "overlayShowWhen".value              = "startMove";       # "I start moving a window"
        "overlayHighlightWhen".value         = "cursorOverInd";   # "My cursor is above the zone indicator"

        "enableEdgeSnapping".value           = false;
        "edgeSnapTriggerDistance".value      = "Medium";

        "rememberWindowGeometries".value     = true;
        "trackActiveLayoutPerScreen".value   = false;
        "autoSnapNewWindows".value           = false;
        "displayOsdMessages".value           = true;
      };

      # Optional: pin built-in KWin tiling padding from your dump
      "kwinrc"."Tiling"."padding".value = 4;

      # (Optional) If you want Xwayland scale pinned
      # "kwinrc"."Xwayland"."Scale".value = 1;
    };

    kwin = {
      nightLight = {
        enable = true;
        mode = "location";
        location.latitude  = "41.8781";
        location.longitude = "-87.6298";
        temperature.day   = 6500;
        temperature.night = 1800;
        transitionTime    = 30;
      };
    };

    shortcuts = {
      kwin = {
        "Walk Through Windows of Current Application" = [ "Alt+`" ];
        "Walk Through Windows of Current Application (Reverse)" = [ "Alt+~" ];
        "Walk Through Windows Alternative" = [ ];
        "Walk Through Windows Alternative (Reverse)" = [ ];
      };
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
          {
            name = "org.kde.plasma.kickoff";
            config = {
              PreloadWeight   = 100;
              popupHeight     = 508;
              popupWidth      = 647;
              "General/icon"  = "distributor-logo-steamdeck";
            };
          }
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              "launchers" = [
                "applications:librewolf-master.desktop"
                "applications:librewolf-professional.desktop"
                "preferred://browser"
                "preferred://filemanager"
                "applications:org.strawberrymusicplayer.strawberry.desktop"
                "applications:steam.desktop"
              ];
              "General/sortingStrategy"   = 0;
              "General/separateLaunchers" = true;
            };
          }
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
          # "org.kde.plasma.showdesktop"
          {
            name = "org.kde.plasma.minimizeall";
            config = {
              immutability = 1;
            };
          }

        ];
      }
    ];

    # Run once at login so you start in sync immediately (after Plasma init)
    startup.desktopScript."sync-wallpapers-on-login" = {
      text = ''"${syncWallpapers}/bin/sync-wallpapers"'';
      priority = 3; # after other Plasma startup scripts
    };
  };

  # Reconfigure KWin so changes take effect without logout
  home.activation.reconfigureKWin = lib.mkAfter ''
    ${pkgs.qt6.qttools}/bin/qdbus org.kde.KWin /KWin reconfigure || true
  '';

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
}
