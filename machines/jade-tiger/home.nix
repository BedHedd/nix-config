# machines/jade-tiger/home.nix
{ pkgs, plasma-manager, ... }:

{
  # 1) import your global home config
  imports = [
    ../../modules/home.nix

    # 2) pull in plasma‑manager’s Home‑Manager module
    plasma-manager.homeManagerModules."plasma-manager"

    # (optional) other per‑host HM modules
    # ../../modules/home-kde.nix
  ];

  # 3) you already set up global packages/programs in modules/home.nix

  # 4) now per‑host plasma‑manager settings:
  programs.plasma-manager.enable   = true;
  programs.plasma-manager.settings = {
    kdeglobals.General.ColorScheme = "Breeze Dark";
    plasmarc.Theme.name           = "breeze";
    # …any other plasma‑manager options…
  };
}

