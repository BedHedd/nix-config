# machines/think-nix/home.nix
{ pkgs, plasma-manager, ... }:

{
  # import your global home.nix (fonts, fish, etc.)
  imports = [ 
    ../../modules/home.nix 
    ../../modules/kde-home.nix

  ];
  
  programs.plasma.workspace.lockAndFeel = lib.mkForce "com.valve.vgui.desktop";

  environment.systemPackages = with pkgs; [
    tlp
  ];
  

}

