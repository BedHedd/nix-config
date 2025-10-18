{ config, lib, pkgs, ... }:

{
  # Default handlers for links/files opened by other apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };

    # Example: keep Dolphin default for directories, but add VSCodium as an option
    associations.added."inode/directory" = [ "vscodium.desktop" ];
    defaultApplications."inode/directory" = [ "org.kde.dolphin.desktop" ];
  };

  # Separate launchers (menu items you can pin to the panel)
  xdg.desktopEntries = {
    librewolf-master = {
      name = "LibreWolf (Master)";
      comment = "LibreWolf with the Master profile";
      exec = ''librewolf --name librewolf-master -P master --no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = {
        X-KDE-WaylandAppId = "librewolf-master";
      };
    };

    librewolf-professional = {
      name = "LibreWolf (Professional)";
      comment = "LibreWolf with the Professional profile";
      exec = ''librewolf --name librewolf-professional -P professional --no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = {
        X-KDE-WaylandAppId = "librewolf-professional";
      };
    };

    librewolf-personal = {
      name = "LibreWolf (Personal)";
      comment = "LibreWolf with the Personal profile";
      exec = ''librewolf --name librewolf-personal -P personal --no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = {
        X-KDE-WaylandAppId = "librewolf-personal";
      };
    };

    librewolf-lan-management = {
      name = "LibreWolf (Lan-Management)";
      comment = "LibreWolf with the Lan-Management profile";
      exec = ''librewolf --name librewolf-lan-management -P lan-management --no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = {
        X-KDE-WaylandAppId = "librewolf-lan-management";
      };
    };

    # Example override you already had
    vscodium = {
      name = "VSCodium";
      genericName = "Source-code Editor";
      exec = "codium %F";
      icon = "vscodium";
      mimeType = [ "inode/directory" ];
      categories = [ "Utility" "Development" "TextEditor" "IDE" ];
      terminal = false;
      type = "Application";
    };
  };
}
