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
    pkgs.runCommand "icons-${name}" {
      buildInputs = [ pkgs.imagemagick pkgs.librsvg pkgs.coreutils ];
    } ''
      set -eu
      outdir="$out/share/icons/hicolor"
      mkdir -p "$outdir"

      HEX=${lib.escapeShellArg hex}

      # 1) Make a large master (do this once)
      master="$(mktemp --suffix=.png)"
      if ${lib.boolToString (builtins.pathExists svgPath)}; then
        ${pkgs.librsvg}/bin/rsvg-convert -w 1024 -h 1024 ${lib.escapeShellArg svgPath} -o "$master"
      else
        ${pkgs.imagemagick}/bin/convert ${basePng} -resize 1024x1024 "$master"
      fi

      # 2) Recolor ONCE at full res: broader fuzz to catch halo pixels; RGB only to preserve alpha
      work="$(mktemp --suffix=.png)"
      cp "$master" "$work"
      for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
        ${pkgs.imagemagick}/bin/convert "$work" \
          -alpha on -channel RGB -fuzz 40% -fill "$HEX" -opaque "$BLUE" +channel \
          "$work"
      done

      # Optional: clamp tiny remaining cyan halos by desaturating very-blue remnants a touch
      ${pkgs.imagemagick}/bin/convert "$work" \
        -alpha on -modulate 100,98,100 +alpha "$work"

      # 3) Downscale the recolored master to all sizes (no new blue is introduced)
      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        mkdir -p "$dir"
        ${pkgs.imagemagick}/bin/convert "$work" \
          -filter Lanczos -define filter:lobes=3 -resize ''${sz}x''${sz} \
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
