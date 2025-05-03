{ lib, pkgs, ... }:

let
  steamdeckPlasma = pkgs.stdenv.mkDerivation rec {
    pname = "steamdeck-plasma-assets";
    version = "0.28";
    src = pkgs.fetchurl {
      url    = "https://github.com/Jovian-Experiments/steamdeck-kde-presets/archive/refs/tags/${version}.tar.gz";
      sha256 = "1jwh9xr44bjxfl7wpj2f4l385qgm98jxfbr9x67q6h9v9v83f32w";   # copy hash from first build
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

