{ config, lib, pkgs, ... }:

let
  # --- Profile colors (your choices) -----------------------------------------
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  # Sizes we’ll generate for PNG
  sizes = [ 16 32 48 64 128 256 512 ];

  # Candidate "LibreWolf blue" shades we’ll replace (case-insensitive-ish).
  # We’ll run -opaque for each with a fuzz so slight variations are caught.
  candidateBlues = [ "#00acff" "#00a9e0" "#23a3dc" "#1ea0db" ];

  # Try stock SVG first (some builds ship it), otherwise we fall back to PNGs.
  svgPath = "${pkgs.librewolf}/share/icons/hicolor/scalable/apps/librewolf.svg";
  hasSvg  = builtins.pathExists svgPath;

  # Find a base PNG from the hicolor tree in the package.
  pngCandidates =
    map (sz: "${pkgs.librewolf}/share/icons/hicolor/${sz}/apps/librewolf.png")
      [ "256x256" "128x128" "64x64" "48x48" "32x32" ];
  basePng =
    let xs = builtins.filter (p: builtins.pathExists p) pngCandidates;
    in if xs == [] then
         throw "LibreWolf icon PNG not found under ${pkgs.librewolf}"
       else
         builtins.head xs;

  # ===== SVG recolor (if present) ============================================
  mkSvg = name: hex:
    pkgs.runCommand "librewolf-${name}.svg" { } ''
      set -eu
      cp ${svgPath} "$out"
      # Replace several likely blues with your target (case-insensitive).
      ${pkgs.gnused}/bin/sed -E -i 's/#(00ACFF|00A9E0|23A3DC|1EA0DB)/${hex}/gI' "$out"
    '';

  svgPersonal     = mkSvg "personal"     colorPersonal;
  svgProfessional = mkSvg "professional" colorProfessional;
  svgMaster       = mkSvg "master"       colorMaster;

  # ===== PNG recolor (fallback / your current case) ==========================
  mkPngSet = name: hex:
    pkgs.runCommand "icons-${name}" { buildInputs = [ pkgs.imagemagick ]; } ''
      set -eu
      outdir="$out/share/icons/hicolor"

      # Recolor helper: run -opaque for each candidate blue with fuzz.
      recolor_png () {
        inpng="$1"; outpng="$2"
        tmp="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.coreutils}/bin/cp "$inpng" "$tmp"
        # Try several likely blues; 35% fuzz gives breathing room across sizes.
        for BLUE in ${lib.concatStringsSep " " (map (b: "'${b}'") candidateBlues)}; do
          ${pkgs.imagemagick}/bin/convert "$tmp" -fuzz 35% -fill '${hex}' -opaque "$BLUE" "$tmp"
        done
        ${pkgs.coreutils}/bin/mv "$tmp" "$outpng"
      }

      # Generate all sizes
      for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
        dir="$outdir/''${sz}x''${sz}/apps"
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        # Resize a fresh copy, then recolor in place
        tmpResized="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.imagemagick}/bin/convert ${basePng} -resize ''${sz}x''${sz} "$tmpResized"
        recolor_png "$tmpResized" "$dir/librewolf-${name}.png"
      done
    '';

  pngPersonal     = mkPngSet "personal"     colorPersonal;
  pngProfessional = mkPngSet "professional" colorProfessional;
  pngMaster       = mkPngSet "master"       colorMaster;

  # Helper: build xdg.dataFile entries for each size pointing at a derivation output
  mkXdgPngFiles = name: drv:
    lib.listToAttrs (map (sz: {
      name  = "icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png";
      value = { source = "${drv}/share/icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png"; };
    }) sizes);

in
# ===== Install into ~/.local/share/icons/hicolor/... =========================
if hasSvg then
{
  # SVG present: install recolored SVGs
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-personal.svg".source     = svgPersonal;
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-professional.svg".source = svgProfessional;
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-master.svg".source       = svgMaster;
}
else
(
  # PNG-only: install generated PNG trees (all sizes) for each profile
  mkXdgPngFiles "personal"     pngPersonal
  // mkXdgPngFiles "professional" pngProfessional
  // mkXdgPngFiles "master"       pngMaster
)
