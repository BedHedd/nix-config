# modules/universal.nix
{ lib, ... }:

{
    time.timeZone        = "America/Chicago";
    i18n.defaultLocale   = "en_US.UTF-8";
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree         = true;
    
    # Home-Manager boiler-plate that applies everywhere
    home-manager.useGlobalPkgs   = true;
    home-manager.useUserPackages = true;
}
