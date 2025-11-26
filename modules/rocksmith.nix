{ config, pkgs, lib, username, ... }:

{
  ### Audio
  services.pipewire.enable = lib.mkDefault true;

  # Add user to audio/rtkit
  users.users.${username}.extraGroups =
    lib.mkAfter [ "audio" "rtkit" ];

  environment.systemPackages =
    (config.environment.systemPackages or []) ++
    (with pkgs; [ helvum rtaudio ]);

  ### Steam
  programs.steam = {
    rocksmithPatch.enable = true;
  };
}
