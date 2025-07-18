
{ config, pkgs, home-manager, plasma-manager, lib, ... }:

let
  username     = "bedhedd";

  # 👇 Define exactly the packages this user wants
  userPackages = with pkgs; [
    # development packages
    uv # python
    vscodium # vscode
    ollama-rocm # ollama local llm
    lmstudio # local llms
    docker # containers
    colima # docker containers

    # graphics and video
    obs-studio # screen recording
    ffmpeg # video encoding
    vlc # media playback
    strawberry
    strawberry
    kdePackages.kdenlive # video editing
    krita # image manipulation
    guake

    # social apps
    vesktop

    # social apps
    vesktop

  ];
in
{
  # 1) Create the UNIX account
  users.extraUsers.${username} = {
      isNormalUser = true;
      home         = "/home/${username}";
      extraGroups  = [ "wheel" ];
    };
  


  # 2) Wire up Home-Manager for devyt
  home-manager.users = {
    "${username}" = {
      home.username      = username;
      home.homeDirectory = "/home/${username}";

      imports = [
        ../modules/home.nix
        ../modules/kde-home.nix
        ../modules/development.nix
        ../modules/guake.nix
        ../modules/development.nix
        ../dotfiles/multiple-ssh.nix
      ];

      programs.fish.enable = true;

      # 3) Inject your per-user package list here
      home.packages = userPackages;
    };
  };
  
}

