{ inputs, hostname, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/desktop-kde.nix
    ../../profiles/users.nix
    ./hardware.nix
  ];

  networking.hostName = hostname;
}
