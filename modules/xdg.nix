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
    librewolf-work = {
      name = "LibreWolf (professional)";
      comment = "LibreWolf with the professional profile";
      exec = "librewolf --class LibreWolf-professional -P professional -no-remote --new-instance %u";
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = {
        StartupWMClass = "LibreWolf-professional";
      };      
    };

    librewolf-personal = {
      name = "LibreWolf (personal)";
      comment = "LibreWolf with the personal profile";
      exec = "librewolf --class LibreWolf-personal -P personal -no-remote --new-instance %u";
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      startupWMClass = "LibreWolf-personal";
      settings = {
        StartupWMClass = "LibreWolf-personal";
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
