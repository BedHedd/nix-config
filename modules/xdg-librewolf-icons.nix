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

      # 1) Make a single high-res recolor using a mask (preserves anti-aliasing)
      workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
      master="$workdir/master.png"
      mask="$workdir/mask.png"
      tmp="$workdir/tmp.png"

      # Start from the best available base (your basePng), do NOT resize yet.
      ${pkgs.coreutils}/bin/cp ${basePng} "$master"

      # Build a mask that ORs all candidate blues together, with a small blur to soften edges.
      # Result: white where the cyan stroke is, black elsewhere.
      ${pkgs.imagemagick}/bin/convert -size "$(${pkgs.imagemagick}/bin/identify -format '%wx%h' "$master")" xc:black "$mask"
      for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
        ${pkgs.imagemagick}/bin/convert "$master" \
          -colorspace sRGB -fuzz 18% -fill white -opaque "$BLUE" \
          -alpha extract -threshold 50% "$tmp"
        ${pkgs.imagemagick}/bin/convert "$mask" "$tmp" -compose Lighten -composite "$mask"
      done
      # Feather the mask slightly to avoid crunchy edges.
      ${pkgs.imagemagick}/bin/convert "$mask" -morphology close disk:1 -blur 0x0.6 "$mask"

      # Create a solid color layer and copy the mask into its alpha, then composite over original.
      ${pkgs.imagemagick}/bin/convert "$master" -fill '${hex}' -colorize 100 "$tmp"
      ${pkgs.imagemagick}/bin/convert "$tmp" "$mask" -compose CopyOpacity -composite "$tmp"
      ${pkgs.imagemagick}/bin/convert "$master" "$tmp" -compose Over -composite "$workdir/recolored.png"

      # 2) Now generate all sizes from the recolored master (better resampling, consistent edges).
      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        ${pkgs.imagemagick}/bin/convert "$workdir/recolored.png" \
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
