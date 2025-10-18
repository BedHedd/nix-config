{ config, lib, pkgs, ... }:

let
  baseSvgPath = "${pkgs.librewolf}/share/icons/hicolor/scalable/apps/librewolf.svg";
  baseSvg     = builtins.readFile baseSvgPath;

  sourceBlues = [
    "#00ACFF" "#00acff"
    "#00A9E0" "#00a9e0"
    "#23A3DC" "#23a3dc"
    "#1EA0DB" "#1ea0db"
  ];

  # Replace all known blues with a single target color
  recolor = target:
    lib.replaceStrings sourceBlues (builtins.map (_: target) sourceBlues) baseSvg;

  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";
in
{
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-personal.svg".text =
    recolor colorPersonal;

  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-professional.svg".text =
    recolor colorProfessional;

  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-master.svg".text =
    recolor colorMaster;
}
