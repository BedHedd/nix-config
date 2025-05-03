{ lib, pkgs, ... }:

let
  steamdeckPlasma = pkgs.stdenv.mkDerivation rec {
    pname = "steamdeck-plasma-assets";
    version = "0.28";
    src = pkgs.fetchurl {
      url    = "https://github.com/Jovian-Experiments/steamdeck-kde-presets/archive/refs/tags/${version}.tar.gz";
      sha256 = "REPLACE-ME";   # copy hash from first build
    };
    installPhase = ''
      mkdir -p $out
      cp -r usr/share $out/
    '';
  };
in {
  environment.systemPackages = [ steamdeckPlasma ];
  environment.pathsToLink    = [ "/usr/share" ];
}

