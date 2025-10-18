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
          colored_rgba="$workdir/colored_rgba.png"
          recolored="$workdir/recolored.png"

          ${pkgs.coreutils}/bin/cp ${basePng} "$master"

          # --- Build ring mask by OR'ing (Lighten) all cyan candidates -----------
          first=1
          for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
            tmp="$workdir/m_$(${pkgs.coreutils}/bin/mktemp -u XXXXX).png"
            # select BLUE-ish pixels → alpha matte → binarize
            ${pkgs.imagemagick}/bin/magick "$master" \
              -colorspace sRGB -fuzz 15% -fill white -opaque "$BLUE" \
              -alpha extract -threshold 45% "$tmp"

            if [ "$first" -eq 1 ]; then
              ${pkgs.coreutils}/bin/cp "$tmp" "$ring_mask"
              first=0
            else
              ${pkgs.imagemagick}/bin/magick "$ring_mask" "$tmp" -compose Lighten -composite "$ring_mask"
            fi
          done
          # soften/close edges a touch
          ${pkgs.imagemagick}/bin/magick "$ring_mask" -morphology close disk:1 -blur 0x0.6 "$ring_mask"

          # --- Build white-protection mask (low saturation & high lightness) -----
          # sat_low = (HSL channel G) < ~12%, light_high = (HSL channel B) > ~70%
          sat="$workdir/sat.png"
          light="$workdir/light.png"
          ${pkgs.imagemagick}/bin/magick "$master" -colorspace HSL -channel G -separate +channel "$sat"
          ${pkgs.imagemagick}/bin/magick "$master" -colorspace HSL -channel B -separate +channel "$light"
          ${pkgs.imagemagick}/bin/magick "$sat" -threshold 12% "$sat"
          ${pkgs.imagemagick}/bin/magick "$light" -threshold 70% "$light"
          ${pkgs.imagemagick}/bin/magick "$sat" "$light" -compose Multiply -composite \
            -morphology open disk:1 -blur 0x0.6 "$white_mask"

          # ring_only = ring_mask AND (NOT white_mask)
          ${pkgs.imagemagick}/bin/magick "$white_mask" -negate "$workdir/white_inv.png"
          ${pkgs.imagemagick}/bin/magick "$ring_mask" "$workdir/white_inv.png" -compose Multiply -composite "$ring_only"

          # --- Make solid color layer, copy ring alpha, composite over original ---
          ${pkgs.imagemagick}/bin/magick "$master" -fill '${hex}' -colorize 100 "$colored"
          ${pkgs.imagemagick}/bin/magick "$colored" "$ring_only" -compose CopyOpacity -composite "$colored_rgba"
          ${pkgs.imagemagick}/bin/magick "$master" "$colored_rgba" -compose Over -composite "$recolored"

          # --- Generate all sizes from the single high-res recolor ----------------
          for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
            dir="$outdir/''${sz}x''${sz}/apps"
            ${pkgs.coreutils}/bin/mkdir -p "$dir"
            ${pkgs.imagemagick}/bin/magick "$recolored" \
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
