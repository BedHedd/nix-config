# lib/autoImport.nix
dir: let
  files = builtins.attrNames (builtins.readDir dir);
  nixFiles = builtins.filter (n: lib.hasSuffix ".nix" n) files;
in map (n: dir + "/${n}") nixFiles
