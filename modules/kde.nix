{ config, pkgs, lib, plasma-manager, ... }:

{
  imports = [
    plasma-manager.nixosModules.default
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  programs.plasma-manager = {
    enable = true;

    settings = {
      kdeglobals = {
        General = {
          ColorScheme = "Breeze Dark";
          Name = "Breeze";
        };
      };

      kwinrc = {
        Plugins = {
          kwin4_effect_zoomEnabled = false;
        };
        MouseBindings = {
          CommandWindow1 = "ExposeAll";
        };
      };

      plasmarc = {
        Theme = {
          name = "breeze";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dolphin
    konsole
    kate
    # more KDE apps
  ];
}

