{ config, lib, pkgs, ... }:

let
  # ---- helpers --------------------------------------------------------------
  svgPath = "${pkgs.librewolf}/share/icons/hicolor/scalable/apps/librewolf.svg";
  hasSvg  = builtins.pathExists svgPath;

  # Common PNG locations shipped by many Firefox/LibreWolf builds
  pngCandidates = map (sz: "${pkgs.librewolf}/share/icons/hicolor/${sz}/apps/librewolf.png")
    [ "32x32" "48x48" "64x64" "128x128" "256x256" ];
  basePng = lib.findFirst builtins.pathExists (throw "LibreWolf icon not found in ${pkgs.librewolf}") pngCandidates;

  # Your colors
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  # Known LibreWolf blues we swap in SVGs
  sourceBlues = [
    "#00ACFF" "#00acff"  # your noted default
    "#00A9E0" "#00a9e0"
    "#23A3DC" "#23a3dc"
    "#1EA0DB" "#1ea0db"
  ];

  # ---- SVG recolor path (preferred if present) ------------------------------
  svgPersonal = pkgs.runCommand "librewolf-personal.svg" {}
    ''
      cp ${svgPath} $out
      ${pkgs.gnused}/bin/sed -i 's/${lib.concatStringsSep "\\|" sourceBlues}/${colorPersonal}/gI' $out
    '';
  svgProfessional = pkgs.runCommand "librewolf-professional.svg" {}
    ''
      cp ${svgPath} $out
      ${pkgs.gnused}/bin/sed -i 's/${lib.concatStringsSep "\\|" sourceBlues}/${colorProfessional}/gI' $out
    '';
  svgMaster = pkgs.runCommand "librewolf-master.svg" {}
    ''
      cp ${svgPath} $out
      ${pkgs.gnused}/bin/sed -i 's/${lib.concatStringsSep "\\|" sourceBlues}/${colorMaster}/gI' $out
    '';

  # ---- PNG recolor path (fallback) ------------------------------------------
  # Generates a small set of sizes in hicolor; recolors the “default blue” to your color.
  mkPngSet = name: hex: pkgs.runCommand "icons-${name}" { buildInputs = [ pkgs.imagemagick ]; }
    ''
      set -eu
      outdir=$out/share/icons/hicolor
      for sz in 32 48 64 128 256; do
        mkdir -p "$outdir/${sz}x${sz}/apps"
        ${pkgs.imagemagick}/bin/convert ${basePng} -resize ${"$"}{sz}x${"$"}{sz} \
          -fuzz 20% -fill '${hex}' -opaque '#00acff' \
          "$outdir/${sz}x${sz}/apps/librewolf-${name}.png"
      done
      # Also drop a 512 if you like:
      mkdir -p "$outdir/512x512/apps"
      ${pkgs.imagemagick}/bin/convert ${basePng} -resize 512x512 \
        -fuzz 20% -fill '${hex}' -opaque '#00acff' \
        "$outdir/512x512/apps/librewolf-${name}.png"
    '';
in
# ---- Expose files into your XDG icon search path ----------------------------
if hasSvg then
{
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-personal.svg".source     = svgPersonal;
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-professional.svg".source = svgProfessional;
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-master.svg".source       = svgMaster;
}
else
let
  pngPersonal     = mkPngSet "personal"     colorPersonal;
  pngProfessional = mkPngSet "professional" colorProfessional;
  pngMaster       = mkPngSet "master"       colorMaster;
in
{
  # copy the whole generated hicolor trees
  xdg.dataFile."icons".source = pngPersonal + "/share/icons";
  xdg.dataFile."icons-2".source = pngProfessional + "/share/icons";
  xdg.dataFile."icons-3".source = pngMaster + "/share/icons";
}
