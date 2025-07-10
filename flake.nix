{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    ############################################################
    # 1) list the platforms you want to support
    ############################################################
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    ############################################################
    # 2) build an `apps` attr-set for every system
    ############################################################
    in {
      apps = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          scriptDrv = pkgs.writeShellScriptBin "host-wizard" ''
            #!${pkgs.runtimeShell}
            export PATH=${pkgs.pciutils}/bin:$PATH
            export REPO_ROOT="$PWD"
            exec ${pkgs.python3}/bin/python ${./scripts/setup-wizard.py} "$@"
          '';
        in {
          type    = "app";
          program = "${scriptDrv}/bin/host-wizard";  # plain string path
        });
    };
}
