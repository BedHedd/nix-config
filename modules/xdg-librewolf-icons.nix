{ config, lib, pkgs, ... }:

let
  # Your profile colors
  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";

  sizes = [ 16 32 48 64 128 256 512 ];

  # --- Embed the upstream LibreWolf SVG (your pasted text) -------------------
  librewolfSvgRaw = ''
    <svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="67.733337mm" height="67.733337mm" viewBox="0 0 67.733337 67.733337" version="1.1" id="svg8" inkscape:version="0.92.4 5da689c313, 2019-01-14" sodipodi:docname="LibreWolf.svg">
      <defs id="defs2"/>
      <sodipodi:namedview id="base" pagecolor="#ffffff" bordercolor="#666666" borderopacity="1.0" inkscape:pageopacity="0.0" inkscape:pageshadow="2" inkscape:zoom="0.9899495" inkscape:cx="-15.106575" inkscape:cy="110.91343" inkscape:document-units="mm" inkscape:current-layer="layer1" showgrid="false" inkscape:window-width="1366" inkscape:window-height="711" inkscape:window-x="0" inkscape:window-y="30" inkscape:window-maximized="1" inkscape:showpageshadow="false" units="px" fit-margin-top="0" fit-margin-left="0" fit-margin-right="0" fit-margin-bottom="0"/>
      <metadata id="metadata5">
        <rdf:RDF>
          <cc:Work rdf:about="">
            <dc:format>image/svg+xml</dc:format>
            <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/>
            <dc:title/>
          </cc:Work>
        </rdf:RDF>
      </metadata>
      <g inkscape:label="Layer 1" inkscape:groupmode="layer" id="layer1" transform="translate(-42.106554,-153.8982)">
        <circle style="fill:#00acff;fill-opacity:1;stroke:none;stroke-width:0.53545821;stroke-miterlimit:4;stroke-dasharray:none" id="path875" cx="75.973221" cy="187.76486" r="33.866669"/>
        <path style="fill:#ffffff;stroke-width:0.13229167" d="m 72.543594,214.67719 ... (unchanged wolf path) ..." id="path847" inkscape:connector-curvature="0"/>
        <path sodipodi:type="star" style="fill:#00acff;fill-opacity:1;stroke:none;stroke-width:1.5;stroke-miterlimit:4;stroke-dasharray:none" id="path814" sodipodi:sides="4" sodipodi:cx="18.854025" sodipodi:cy="172.98837" sodipodi:r1="1.6036172" sodipodi:r2="1.1339285" sodipodi:arg1="1.5707963" sodipodi:arg2="2.3561945" inkscape:flatsided="true" inkscape:rounded="0" inkscape:randomized="0" d="m 18.854025,174.59199 -1.603617,-1.60362 1.603617,-1.60361 1.603617,1.60361 z" transform="matrix(0.23203125,0.40188991,-0.99392962,0.57384553,246.21921,73.888081)"/>
      </g>
    </svg>
  '';

  # Utility: make an icon set for a given name & hex color by replacing #00acff in the SVG.
  mkIconSet = name: hex:
    let
      # Replace both ring & star blue fills with your color at eval time
      coloredSvgText = builtins.replaceStrings [ "#00acff" "#00ACFF" ] [ hex hex ] librewolfSvgRaw;
      coloredSvgFile = pkgs.writeText "librewolf-${name}.svg" coloredSvgText;
    in
    pkgs.runCommand "librewolf-icons-${name}"
      { buildInputs = [ pkgs.librsvg pkgs.imagemagick pkgs.coreutils ]; }
      ''
        set -eu
        out="$out/share/icons/hicolor"
        mkdir -p "$out/scalable/apps"
        # Install the recolored SVG verbatim
        cp ${coloredSvgFile} "$out/scalable/apps/librewolf-${name}.svg"

        # Rasterize PNGs from the recolored SVG (sharp at all sizes)
        for sz in ${lib.concatStringsSep " " (map toString sizes)}; do
          dir="$out/''${sz}x''${sz}/apps"
          mkdir -p "$dir"
          ${pkgs.librsvg}/bin/rsvg-convert -w "$sz" -h "$sz" "$out/scalable/apps/librewolf-${name}.svg" \
            | ${pkgs.imagemagick}/bin/magick - -strip "$dir/librewolf-${name}.png"
        done
      '';

  drvPersonal     = mkIconSet "personal"     colorPersonal;
  drvProfessional = mkIconSet "professional" colorProfessional;
  drvMaster       = mkIconSet "master"       colorMaster;

  mkXdgFiles = name: drv:
    let
      pngs = lib.listToAttrs (map (sz: {
        name  = "icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png";
        value = { source = "${drv}/share/icons/hicolor/${toString sz}x${toString sz}/apps/librewolf-${name}.png"; };
      }) sizes);
      svg  = {
        "icons/hicolor/scalable/apps/librewolf-${name}.svg".source =
          "${drv}/share/icons/hicolor/scalable/apps/librewolf-${name}.svg";
      };
    in pngs // svg;

in {
  xdg.dataFile =
    mkXdgFiles "personal"      drvPersonal
    // mkXdgFiles "professional" drvProfessional
    // mkXdgFiles "master"        drvMaster;
}
