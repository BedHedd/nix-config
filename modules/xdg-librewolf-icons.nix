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
      pkgs.runCommand "icons-${name}" { buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; } ''
        set -eu
        outdir="$out/share/icons/hicolor"
        mkdir -p "$outdir"

        workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
        master="$workdir/master.png"
        ring_mask="$workdir/ring_mask.png"
        white_mask="$workdir/white_mask.png"
        ring_only="$workdir/ring_only.png"
        colored="$workdir/colored.png"
        recolored="$workdir/recolored.png"

        ${pkgs.coreutils}/bin/cp ${basePng} "$master"

        # --- Build ring mask (cyan-ish stroke only) ----------------------------
        # Start with union of all cyan candidates, then soften/close edges.
        ${pkgs.imagemagick}/bin/convert -size "$(${pkgs.imagemagick}/bin/identify -format '%wx%h' "$master")" xc:black "$ring_mask"
        for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
          ${pkgs.imagemagick}/bin/convert "$master" \
            -colorspace sRGB -fuzz 15% -fill white -opaque "$BLUE" \
            -alpha extract -threshold 45% mpr:one
          ${pkgs.imagemagick}/bin/convert "$ring_mask" mpr:one -compose Lighten -composite "$ring_mask"
        done
        ${pkgs.imagemagick}/bin/convert "$ring_mask" -morphology close disk:1 -blur 0x0.6 "$ring_mask"

        # --- Build protection mask for the wolf (white/neutral & bright) -------
        # Low saturation AND high lightness ≈ white silhouette; clean it up a bit.
        ${pkgs.imagemagick}/bin/convert "$master" -colorspace HSL \
          -channel G -separate -threshold 12% mpr:sat_low       \  # low S
          -channel B -separate -threshold 70% mpr:light_high    # high L
        ${pkgs.imagemagick}/bin/convert mpr:sat_low mpr:light_high -compose Multiply -composite \
          -morphology open disk:1 -blur 0x0.6 "$white_mask"

        # --- Keep only the ring: ring_mask minus white_mask --------------------
        # ring_only = ring_mask AND (NOT white_mask)
        ${pkgs.imagemagick}/bin/convert "$white_mask" -negate mpr:white_inv
        ${pkgs.imagemagick}/bin/convert "$ring_mask" mpr:white_inv -compose Multiply -composite "$ring_only"

        # --- Color layer with ring_only as alpha, composite over original ------
        ${pkgs.imagemagick}/bin/convert "$master" -fill '${hex}' -colorize 100 "$colored"
        ${pkgs.imagemagick}/bin/convert "$colored" "$ring_only" -compose CopyOpacity -composite "$colored"
        ${pkgs.imagemagick}/bin/convert "$master" "$colored" -compose Over -composite "$recolored"

        # --- Downscale cleanly to all sizes ------------------------------------
        for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
          dir="$outdir/''${sz}x''${sz}/apps"
          ${pkgs.coreutils}/bin/mkdir -p "$dir"
          ${pkgs.imagemagick}/bin/convert "$recolored" \
            -filter Lanczos -define filter:lobes=3 \
            -resize ''${sz}x''${sz} \
            -unsharp 0x0.75+0.75+0.02 \
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

in
{
  # ✅ ALWAYS nest under xdg.dataFile
  xdg.dataFile =
    mkXdgPngFiles "personal"     pngPersonal
    // mkXdgPngFiles "professional" pngProfessional
    // mkXdgPngFiles "master"       pngMaster;
}
