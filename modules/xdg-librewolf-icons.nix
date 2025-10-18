{ config, lib, pkgs, ... }:

let
  # Your palette
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  sizes = [ 16 32 48 64 128 256 512 ];
  candidateBlues = [ "#00acff" "#00a9e0" "#23a3dc" "#1ea0db" ];

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
    pkgs.runCommand "icons-${name}" {
      buildInputs = [ pkgs.imagemagick pkgs.librsvg pkgs.coreutils ];
    } ''
      set -eu
      outdir="$out/share/icons/hicolor"
      mkdir -p "$outdir"

      # Nix-escaped values
      HEX=${lib.escapeShellArg hex}

      render_base () {
        # $1 = target size (e.g. 128)
        # print path to a temp PNG at that size
        sz="$1"
        tmp="$(mktemp --suffix=.png)"
        if ${lib.boolToString baseIsSvg}; then
          ${pkgs.librsvg}/bin/rsvg-convert -w "$sz" -h "$sz" ${lib.escapeShellArg svgPath} -o "$tmp"
        else
          ${pkgs.imagemagick}/bin/convert ${basePng} -resize ''${sz}x''${sz} "$tmp"
        fi
        printf "%s\n" "$tmp"
      }

      recolor_into () {
        # $1 = inpng, $2 = outpng
        inpng="$1"; outpng="$2"
        # Work on RGB only; keep alpha untouched to avoid halos
        work="$(mktemp --suffix=.png)"
        cp "$inpng" "$work"

        # Slightly stricter fuzz to avoid re-coloring greys/whites unintentionally
        for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
          ${pkgs.imagemagick}/bin/convert "$work" \
            -alpha on -channel RGB -fuzz 20% -fill "$HEX" -opaque "$BLUE" +channel \
            "$work"
        done
        mv "$work" "$outpng"
      }

      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        mkdir -p "$dir"
        base_png="$(render_base "$sz")"
        recolor_into "$base_png" "$dir/librewolf-${name}.png"
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
