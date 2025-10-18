{ config, lib, pkgs, ... }:

let
  baseSvgPath = "${pkgs.librewolf}/share/icons/hicolor/scalable/apps/librewolf.svg";
  baseSvg     = builtins.readFile baseSvgPath;

  # Known LibreWolf blues (cover case variants)
  sourceBlues = [
    "#00ACFF" "#00acff"
    "#00A9E0" "#00a9e0"
    "#23A3DC" "#23a3dc"
    "#1EA0DB" "#1ea0db"
  ];

  recolor = target:
    lib.foldl' (acc: src -> lib.replaceStrings [src] [target] acc) baseSvg sourceBlues;

  colorPersonal     = "#8d4953";
  colorProfessional = "#5b7b65";
  colorMaster       = "#0e0e0e";  # near-black
in
{
  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-personal.svg".text =
    recolor colorPersonal;

  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-professional.svg".text =
    recolor colorProfessional;

  xdg.dataFile."icons/hicolor/scalable/apps/librewolf-master.svg".text =
    recolor colorMaster;
}
