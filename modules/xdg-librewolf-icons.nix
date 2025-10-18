{ config, lib, pkgs, ... }:

let
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  sizes = [ 16 32 48 64 128 256 512 ];
  candidateBlues = [ "#00acff" "#00a9e0" "#23a3dc" "#1ea0db" ];

  # Find a base PNG from the hicolor tree in the package (don’t pathExists on derivations conditionally at eval).
  pngCandidates =
    map (sz: "${pkgs.librewolf}/share/icons/hicolor/${sz}/apps/librewolf.png")
      [ "256x256" "128x128" "64x64" "48x48" "32x32" ];
  basePng =
    let xs = builtins.filter (p: builtins.pathExists p) pngCandidates;
    in if xs == [] then
         throw "LibreWolf icon PNG not found under ${pkgs.librewolf}"
       else
         builtins.head xs;

  mkPngSet = name: hex:
    pkgs.runCommand "icons-${name}" { buildInputs = [ pkgs.imagemagick ]; } ''
      set -eu
      outdir="$out/share/icons/hicolor"

      recolor_png () {
        inpng="$1"; outpng="$2"
        tmp="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.coreutils}/bin/cp "$inpng" "$tmp"
        for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
          ${pkgs.imagemagick}/bin/convert "$tmp" -fuzz 35% -fill '${hex}' -opaque "$BLUE" "$tmp"
        done
        ${pkgs.coreutils}/bin/mv "$tmp" "$outpng"
      }

      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        tmpResized="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.imagemagick}/bin/convert ${basePng} -resize ''${sz}x''${sz} "$tmpResized"
        recolor_png "$tmpResized" "$dir/librewolf-${name}.png"
      done
    '';

  pngPersonal     = mkPngSet "personal"     colorPersonal;
  pngProfessional = mkPngSet "professional" colorProfessional;
  pngMaster       = mkPngSet "master"       colorMaster;

  mkXdgPngFiles = name: drv:
    lib.listToAttrs (map (sz: {
      name  = "icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png";
      value = { source = "${drv}/share/icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png"; };
    }) sizes);

in
{
  # ✅ ALWAYS nest under xdg.dataFile
  xdg.dataFile =
    mkXdgPngFiles "personal"     pngPersonal
    // mkXdgPngFiles "professional" pngProfessional
    // mkXdgPngFiles "master"       pngMaster;
}
