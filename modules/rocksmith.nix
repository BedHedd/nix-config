# modules/rocksmith.nix
{ config, pkgs, ... }:

let
  # replace this with your actual login name
  username = "bedhedd";
in
{
  ### Audio
  services.pipewire.enable = true;

  # Add user to `audio` and `rtkit` groups.
  users.users.${username}.extraGroups = [ "audio" "rtkit" ];

  environment.systemPackages = with pkgs; [
    helvum # Lets you view pipewire graph and connect IOs
    rtaudio
  ];

  ### Steam (https://nixos.wiki/wiki/Steam)
  programs.steam = {
    enable = true;
    rocksmithPatch.enable = true;
  };
}
