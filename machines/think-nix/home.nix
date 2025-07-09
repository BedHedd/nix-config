# machines/think-nix/home.nix
{ pkgs, plasma-manager, ... }:

{
  # import your global home.nix (fonts, fish, etc.)
  imports = [ 
    ../../modules/home.nix 
    ../../modules/kde-home.nix

  ];
  
  environment.systemPackages = with pkgs; [
    tlp
  ];
  

}

