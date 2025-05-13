{ config, pkgs, home-manager, plasma-manager, lib, ... }:

let
  username     = "admin";

  # 👇 Define exactly the packages this user wants
  userPackages = with pkgs; [
    vscodium
    # add more here, e.g.
    # docker
    # firefox
  ];
in
{
  # 1) Create the UNIX account
  users.extraUsers.${username} = {
      isNormalUser = true;
      home         = "/home/${username}";
      extraGroups  = [ "wheel" ];
    };
  


  # 2) Wire up Home-Manager for dev
  home-manager.users = {
    "${username}" = {
      home.username      = username;
      home.homeDirectory = "/home/${username}";

      imports = [
        ../modules/home.nix
        (import ../modules/kde-home.nix { inherit pkgs plasma-manager lib; })
      ];

      programs.fish.enable = true;

      # 3) Inject your per-user package list here
      home.packages = userPackages;
    };
  };
}

