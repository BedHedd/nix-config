# modules/development.nix  ── always-on Home-Manager module
{ pkgs, lib, ... }:

let
  # Pick your default interpreter here (swap for python312, python310, …)
  python = pkgs.python311;
in
{
  ##########################################################################
  # Packages added to the user profile
  ##########################################################################
  home.packages = with pkgs; [
    uv
    nodejs_20                       # helper scripts used by Playwright
    playwright-driver.browsers      # patched Chromium / Firefox / WebKit
    gcc                             # compile native wheels
    fastfetch                       # misc CLI goodies
    # selenium dependencies
    chromium                        # for selenium
    chromium.chromedriver
    glib                            
    cacert

    # Wrapper so wheels can find libstdc++, libgcc_s, etc. at runtime
    (pkgs.writeShellScriptBin "python3" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${python}/bin/python3 "$@"
    '')
  ];

  ##########################################################################
  # Environment variables for every shell (bash, zsh, fish …)
  ##########################################################################
  home.sessionVariables = {
    LD_LIBRARY_PATH =
      "${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}:$LD_LIBRARY_PATH";
    
    PLAYWRIGHT_BROWSERS_PATH =
      "${pkgs.playwright-driver.browsers}";
    
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    
    SE_CHROMEDRIVER = "${pkgs.chromium.chromedriver}/bin/chromedriver";
  };

  ##########################################################################
  # Extra initialisation for fish (runs only when the interactive shell is fish)
  ##########################################################################
  programs.fish.shellInit = ''
    # Playwright on NixOS
    set -gx PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers}
    set -gx PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS true

    # Tell uv to prefer its own managed runtimes; unset hard pins
    if not set -q UV_PYTHON_PREFERENCE
        set -Ux UV_PYTHON_PREFERENCE only-managed
    end
    set -e UV_PYTHON
  '';
}
