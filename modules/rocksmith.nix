# modules/rocksmith.nix
{ config, pkgs, lib, username, ... }:

let
  # Import nixos-rocksmith via default.nix, no flake input needed
  nixos-rocksmith =
    import (builtins.fetchTarball "https://github.com/re1n0/nixos-rocksmith/archive/master.tar.gz") {};
in
{
  # Pull in the upstream module so the option exists
  imports = [
    nixos-rocksmith.nixosModules.default
  ];

  ### Audio
  services.pipewire.enable = lib.mkDefault true;

  # Add user to audio/rtkit
  users.users.${username}.extraGroups =
    lib.mkAfter [ "audio" "rtkit" ];

  environment.systemPackages =
    (config.environment.systemPackages or []) ++
    (with pkgs; [ helvum rtaudio ]);

  ### Steam + Rocksmith
  programs.steam = {
    rocksmithPatch.enable = true;
  };
}
