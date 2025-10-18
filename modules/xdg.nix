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
      name = "LibreWolf (Professional)";
      exec = ''env MOZ_ENABLE_WAYLAND=0 librewolf --class LibreWolf-Professional -P Work -no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = { StartupWMClass = "LibreWolf-Work"; };
    };

    librewolf-personal = {
      name = "LibreWolf (Personal)";
      exec = ''env MOZ_ENABLE_WAYLAND=0 librewolf --class LibreWolf-Personal -P Personal -no-remote --new-instance %u'';
      icon = "librewolf";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
      settings = { StartupWMClass = "LibreWolf-Personal"; };
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
