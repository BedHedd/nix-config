{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      scriptDrv = pkgs.writeShellScriptBin "host-wizard" ''
        #!${pkgs.runtimeShell}
        export PATH=${pkgs.pciutils}/bin:$PATH           # for lspci
        export REPO_ROOT="$PWD"                          # ← add this line
        exec ${pkgs.python3}/bin/python ${./scripts/setup-wizard.py} "$@"
      '';
    in {
      apps.host-wizard = {
        type    = "app";
        program = "${scriptDrv}/bin/host-wizard";
      };
    }
}
