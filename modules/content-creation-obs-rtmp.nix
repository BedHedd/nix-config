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
      pkgs.qt6.qtbase  # or pkgs.qt5.qtbase on your channel
    ];

    cmakeFlags = [
      (lib.cmakeBool "ENABLE_QT" true)
      (lib.cmakeBool "ENABLE_FRONTEND_API" true)
      (lib.cmakeBool "CMAKE_COMPILE_WARNING_AS_ERROR" false)
    ];

    dontWrapQtApps = true;

    # IMPORTANT: remove the old postInstall that moves from $out/dist
    # CMake's default install already puts:
    #   lib/obs-plugins/obs-multi-rtmp.so
    #   share/obs/obs-plugins/obs-multi-rtmp/...
    # so no extra moves needed.

    meta = {
      homepage   = "https://github.com/sorayuki/obs-multi-rtmp/";
      changelog  = "https://github.com/sorayuki/obs-multi-rtmp/releases/tag/${version}";
      description = "Multi-site simultaneous broadcast plugin for OBS Studio";
      license    = lib.licenses.gpl2Only;
      inherit (pkgs.obs-studio.meta) platforms;
    };
  };
in
{
  programs.obs-studio = {
    enable = true;
    plugins = [ obsMultiRtmp ];
  };
}
