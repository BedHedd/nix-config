# modules/steamdeck-plasma.nix
{ config, lib, pkgs, ... }:

let
  # ── 1. Build a tiny package with *only* usr/share/* from Valve’s tarball ──
  steamdeckPlasma = pkgs.stdenv.mkDerivation rec {
    pname   = "steamdeck-plasma-assets";
    version = "0.28";               # 0.28 is the newest tag as of 2025‑05

    src = pkgs.fetchurl {
      url =
        "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/steamdeck-kde-presets-${version}.src.tar.gz";
      # First build will print a hash mismatch → copy the “got: …” hash here
      sha256 = lib.fakeSha256;   # <- replace after first build
    };

    # Tarball layout = usr/ … etc/ … ; we want only usr/share/**
    installPhase = ''
      mkdir -p $out
      cp -r usr/share $out/
    '';
  };
in
{
  #### 2. Make Plasma see the assets #########################################

  environment.systemPackages = [ steamdeckPlasma ];

  # expose icons, cursors, the lnf package, colour‑schemes, wallpapers, …
  environment.pathsToLink = [ "/usr/share" ];

  #### 3. Switch the user session to Valve’s look‑and‑feel ###################

  # If you configure Plasma via Home‑Manager:
  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = "org.kde.vapor.desktop";  # Valve’s LNF package
  };

  # If you control Plasma from NixOS level instead, move the stanza above
  # into your kde-home.nix (or equivalent HM module).
}

