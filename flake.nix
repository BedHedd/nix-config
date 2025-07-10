{
  inputs = {
    nixpkgs.url       = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url   = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs for THIS system → gives us `pkgs`
        pkgs = import nixpkgs { inherit system; };

        # Build a tiny wrapper that:
        #   • puts pciutils (lspci) on PATH
        #   • passes the repo directory via $REPO_ROOT
        #   • runs the Python wizard
        scriptDrv = pkgs.writeShellScriptBin "host-wizard" ''
          #!${pkgs.runtimeShell}
          export PATH=${pkgs.pciutils}/bin:$PATH
          export REPO_ROOT="$PWD"
          exec ${pkgs.python3}/bin/python ${./scripts/setup-wizard.py} "$@"
        '';
      in {
        apps.host-wizard = flake-utils.lib.mkApp {
          drv = scriptDrv;                 # mkApp returns just the path string
        };
      });
}
