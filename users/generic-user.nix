# users/generic-user.nix
{ config, pkgs, home-manager, plasma-manager, lib, ... }:

let
  username     = "__USERNAME__";   # ← token the script will replace
  userPackages = with pkgs; [
    # add account specific packages here
  ];
in
{
  users.extraUsers.${username} = {
    isNormalUser = true;
    home         = "/home/${username}";
    extraGroups  = [ "wheel" ];
  };

  home-manager.users.${username} = {
    home.username      = username;
    home.homeDirectory = "/home/${username}";
    imports = [
      ../modules/kde-home.nix
      ../modules/guake.nix
      # uncomment development if you need python, uv, selenium, and playwright      
      # ../modules/development.nix
      # ../dotfiles/multiple-ssh.nix
    ];
    programs.fish.enable = true;
    home.packages        = userPackages;
  };
}
