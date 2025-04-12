{ config, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.users.admin = import ./home.nix;
}
