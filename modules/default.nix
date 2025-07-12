# modules/default.nix
{
  universal = ./universal.nix;
  linux     = ./linux.nix;
  kde       = ./kde.nix;
  kdeHome   = ./kde-home.nix;
  steamdeck = ./steamdeck-plasma-system.nix;
  globalHome = ./home.nix;
}
