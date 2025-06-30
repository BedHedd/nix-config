# machines/jade-tiger/home.nix
{ pkgs, plasma-manager, ... }:

{
  # import your global home.nix (fonts, fish, etc.)
  imports = [ 
    ../../modules/home.nix 
    ../../modules/kde-home.nix
    ../../modules/nix-ld.nix

  ];

}

