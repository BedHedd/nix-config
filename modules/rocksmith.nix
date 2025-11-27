{ config, lib, pkgs, username, ... }:

let
  # Pull nixos-rocksmith via default.nix (no flake input needed)
  nixos-rocksmith =
    import (builtins.fetchTarball
      "https://github.com/re1n0/nixos-rocksmith/archive/master.tar.gz") {};

  cfg = config.profiles.rocksmith;
in
{
  # Load upstream module so programs.steam.rocksmithPatch exists
  imports = [
    nixos-rocksmith.nixosModules.default
  ];

  options.profiles.rocksmith.enable =
    lib.mkEnableOption "Enable Rocksmith patch, Steam, and audio wiring";

  config = lib.mkIf cfg.enable {
    ### Steam + Rocksmith
    programs.steam = {
      enable = lib.mkDefault true;
      rocksmithPatch.enable = true;
    };

    ### Audio
    services.pipewire.enable = lib.mkDefault true;

    users.users.${username}.extraGroups =
      lib.mkAfter [ "audio" "rtkit" ];

    environment.systemPackages =
      (config.environment.systemPackages or []) ++
      (with pkgs; [ helvum rtaudio ]);
  };
}
