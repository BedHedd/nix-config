# machines/think-nix/home.nix
{ pkgs, plasma-manager, ... }:

{
  # import your global home.nix (fonts, fish, etc.)
  imports = [ 
    plasma-manager.homeModule 
    ../../modules/home.nix 
    ../../modules/kde-home.nix

  ];
  
  programs.plasma.workspace.lookAndFeel = "com.valve.vgui.desktop";

  environment.systemPackages = with pkgs; [
    tlp
  ];
  

}

