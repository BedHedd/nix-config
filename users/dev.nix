{ config, pkgs, home-manager, plasma-manager, lib, ... }:

let
  username     = "dev";

  # 👇 Define exactly the packages this user wants
  userPackages = with pkgs; [
    # development packages
    uv # python
    vscodium # vscode
    ollama-rocm # ollama
    docker
    colima # docker containers

    # graphics and video
    obs-studio # screen recording
    kdePackages.kdenlive # video editing
    krita # image manipulation
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
        ../modules/kde-home.nix
      ];

      programs.fish.enable = true;

      # 3) Inject your per-user package list here
      home.packages = userPackages;
    };
  };
}

