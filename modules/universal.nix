# modules/universal.nix
{ lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree         = true;

  # Home-Manager boiler-plate that applies everywhere
  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;
}
