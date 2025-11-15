{ lib, pkgs, ... }:

let
  obsMultiRtmp = pkgs.stdenv.mkDerivation rec {
    pname = "obs-multi-rtmp";
    version = "0.7.3.2";

    src = pkgs.fetchFromGitHub {
      owner = "sorayuki";
      repo  = "obs-multi-rtmp";
      rev   = "fd41bfdd07d45545dcc6895cbd65bbcac1d49fd5";
      hash  = "sha256-edhJU06sT+pPovGcMJu4gAYbyaBKZBwSNifvXW06Ui8=";
    };

    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [
      pkgs.obs-studio
      pkgs.qt6.qtbase   # <- changed from pkgs.qtbase
    ];

    cmakeFlags = [
      (lib.cmakeBool "ENABLE_QT" true)
      (lib.cmakeBool "ENABLE_FRONTEND_API" true)
      (lib.cmakeBool "CMAKE_COMPILE_WARNING_AS_ERROR" false)
    ];

    dontWrapQtApps = true;

    postInstall = ''
      mkdir -p $out/{lib,share/obs/obs-plugins/}
      mv $out/dist/obs-multi-rtmp/data $out/share/obs/obs-plugins/obs-multi-rtmp
      mv $out/dist/obs-multi-rtmp/bin/64bit $out/lib/obs-plugins
      rm -rf $out/dist
    '';
  };
in {
  programs.obs-studio = {
    enable = true;
    plugins = [ obsMultiRtmp ];
  };
}
