{ config, lib, pkgs, ... }:

let
  # Your palette
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  sizes = [ 16 32 48 64 128 256 512 ];
  candidateBlues = [
    # originals
    "#00acff" "#00a9e0" "#23a3dc" "#1ea0db"
    # common ring/halo variants (lighter/darker cyans)
    "#00b4ff" "#00bfff" "#00c0ff" "#00ccff" "#00d4ff" "#00e5ff" "#18ffff"
    "#26c6da" "#29b6f6" "#33b5e5" "#40c4ff" "#4dd0e1" "#80deea"
  ];

  # Prefer SVG if present (sharper at big sizes); else choose the largest PNG available.
  svgPath = "${pkgs.librewolf}/share/icons/hicolor/scalable/apps/librewolf.svg";
  pngCandidates =
    map (sz: "${pkgs.librewolf}/share/icons/hicolor/${sz}/apps/librewolf.png")
      [ "512x512" "256x256" "128x128" "64x64" "48x48" "32x32" ];

  baseIsSvg = builtins.pathExists svgPath;
  basePng =
    let xs = builtins.filter (p: builtins.pathExists p) pngCandidates;
    in if xs == [] then
         throw "LibreWolf icon PNG not found under ${pkgs.librewolf}"
       else
         builtins.head xs;

  mkPngSet = name: hex:
    pkgs.runCommand "icons-${name}" { buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; } ''
      set -eu
      outdir="$out/share/icons/hicolor"
      mkdir -p "$outdir"

      IM=${pkgs.imagemagick}/bin/magick
      ID=${pkgs.imagemagick}/bin/identify
      CP=${pkgs.coreutils}/bin/cp
      MKDIR=${pkgs.coreutils}/bin/mkdir
      MKTEMP=${pkgs.coreutils}/bin/mktemp

      workdir="$($MKTEMP -d)"
      master="$workdir/master.png"
      ringMask="$workdir/ringMask.png"
      wolfMask="$workdir/wolfMask.png"
      tmp="$workdir/tmp.png"

      # 0) Source image (do NOT resize yet)
      $CP ${basePng} "$master"
      WH="$($ID -format '%wx%h' "$master")"

      # ------------------------------------------------
      # 1) Build ring mask (union of candidate cyans)
      # ------------------------------------------------
      # Start with a black canvas at the same size
      $IM -size "$WH" xc:black "$ringMask"

      for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
        # White where pixels match BLUE (with fuzz), then extract alpha-ish edge and threshold
        $IM "$master" \
          -colorspace sRGB -fuzz 22% -fill white -opaque "$BLUE" \
          -alpha extract -threshold 50% "$tmp"
        # Lighten-composite into ringMask to OR the selections
        $IM "$ringMask" "$tmp" -compose Lighten -composite "$ringMask"
      done
      # Feather edges for smoother anti-aliasing
      $IM "$ringMask" -morphology close disk:1 -blur 0x0.6 "$ringMask"

      # ----------------------------------------------------
      # 2) Build wolf mask (near-white, low-sat & bright),
      #    then subtract ring so we don't touch the stroke
      # ----------------------------------------------------
      sat="$workdir/sat.png"
      lig="$workdir/lig.png"
      nearWhite="$workdir/nearwhite.png"

      $IM "$master" -colorspace HSL -channel saturation -separate +channel "$sat"
      $IM "$master" -colorspace HSL -channel lightness  -separate +channel "$lig"

      # Low saturation (<= ~12%) AND high lightness (>= ~70%)
      $IM "$sat" -threshold 12% -negate "$sat"
      $IM "$lig" -threshold 70% "$lig"
      $IM "$sat" "$lig" -compose Multiply -composite "$nearWhite"

      # Subtract ring area so we don’t paint the stroke white
      # Use MinusSrc for IM7
      $IM "$nearWhite" "$ringMask" -compose MinusSrc -composite "$wolfMask"
      $IM "$wolfMask" -morphology open disk:1 "$wolfMask"

      # ------------------------------
      # 3) Recolor ONLY the ring
      # ------------------------------
      colorLayer="$workdir/color.png"
      $IM "$master" -fill '${hex}' -colorize 100 "$colorLayer"
      $IM "$colorLayer" "$ringMask" -compose CopyAlpha -composite "$colorLayer"
      recolored="$workdir/recolored.png"
      $IM "$master" "$colorLayer" -compose Over -composite "$recolored"

      # -------------------------------------
      # 4) Force the wolf back to pure white
      # -------------------------------------
      whiteLayer="$workdir/white.png"
      final="$workdir/final.png"
      $IM "$recolored" -fill white -colorize 100 "$whiteLayer"
      $IM "$whiteLayer" "$wolfMask" -compose CopyAlpha -composite "$whiteLayer"
      $IM "$recolored" "$whiteLayer" -compose Over -composite "$final"

      # -------------------------
      # 5) Downscale to all sizes
      # -------------------------
      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        $MKDIR -p "$dir"
        $IM "$final" -filter Lanczos -define filter:lobes=3 \
          -resize ''${sz}x''${sz} -unsharp 0x0.75+0.75+0.02 \
          "$dir/librewolf-${name}.png"
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

in {
  xdg.dataFile =
    mkXdgPngFiles "personal"      pngPersonal
    // mkXdgPngFiles "professional" pngProfessional
    // mkXdgPngFiles "master"        pngMaster;
}
