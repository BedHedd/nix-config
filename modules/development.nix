# modules/development.nix  ── always-on Home-Manager module
{ pkgs, lib, config, ... }:

let
  # Pick your default interpreter here (swap for python312, python310, …)
  python = pkgs.python311;

  # Where Bun will place global packages and shims (XDG-friendly)
  bunInstall = "${config.xdg.dataHome}/bun";  # e.g., ~/.local/share/bun
in
{
  ##########################################################################
  # Packages added to the user profile
  ##########################################################################
  home.packages = with pkgs; [
    uv
    bun                             # ← Bun runtime & bunx
    git-lfs
    nodejs_20
    playwright-driver.browsers
    gcc
    zig
    fastfetch
    chromium
    chromedriver
    undetected-chromedriver
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
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    # Helps Node/Bun TLS trust the same CA bundle:
    NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    LD_LIBRARY_PATH =
      "${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}:$LD_LIBRARY_PATH";

    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    SE_CHROMEDRIVER = "${pkgs.chromedriver}/bin/chromedriver";

    # Bun global install/cache root (writeable by user)
    BUN_INSTALL = bunInstall;
  };

  # Ensure Bun’s shims (installed via `bun add -g <pkg>`) are on PATH
  home.sessionPath = [ "${bunInstall}/bin" ];

  ##########################################################################
  # Extra initialisation for fish (runs only when the interactive shell is fish)
  ##########################################################################
  programs.fish.shellInit = ''
    # --- existing ---
    set -gx SSL_CERT_FILE ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    set -gx SE_CHROMEDRIVER ${pkgs.chromedriver}/bin/chromedriver

    # uv: prefer managed runtimes; unset hard pins
    if not set -q UV_PYTHON_PREFERENCE
        set -Ux UV_PYTHON_PREFERENCE only-managed
    end
    set -e UV_PYTHON

    # --- bun: uvx-style setup ---
    # Ensure BUN_INSTALL is set & its bin is on PATH
    if not set -q BUN_INSTALL
        set -Ux BUN_INSTALL $XDG_DATA_HOME/bun
    end
    if not contains $BUN_INSTALL/bin $PATH
        set -gx PATH $BUN_INSTALL/bin $PATH
    end

    # Make a tiny uvx-like shorthand for bunx
    functions -q bx; or function bx; command bunx $argv; end

    # Prefer bunx/`bun add -g` for globals; keep npm from hijacking
    set -e npm_config_prefix >/dev/null 2>&1
  '';
}
