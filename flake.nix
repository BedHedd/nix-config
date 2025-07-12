{
  ########################################################################
  # 1  Inputs                                                             #
  ########################################################################
  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url   = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows   = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, nixos-hardware, ... }:
  ########################################################################
  # 2  Helper: enumerate host folders                                    #
  ########################################################################
  let
    hostNames =
      builtins.filter
        (name: builtins.pathExists (./hosts/${name}/default.nix))
        (builtins.attrNames (builtins.readDir ./hosts));

    # If you need per-host system types, put a `system = "x86_64-linux";`
    # line in each hosts/<name>/default.nix and read it here with import.
    defaultSystem = "x86_64-linux";

    extraModules = import ./modules;   # attr-set with .universal .linux …

    mkSpecialArgs = {
      inherit home-manager plasma-manager nixos-hardware extraModules;
    };

  ########################################################################
  # 3  Build nixosConfigurations attr-set                                #
  ########################################################################
    nixosCfgs =
      nixpkgs.lib.genAttrs hostNames (host:
        nixpkgs.lib.nixosSystem {
          system  = defaultSystem;
          modules =
            [ ./hosts/${host}/default.nix ]
            ++ nixpkgs.lib.optionals (defaultSystem == "x86_64-linux") [ extraModules.kde ];
          specialArgs = mkSpecialArgs // { inherit host; };
        });

  ########################################################################
  # 4  setup-wizard app (unchanged)                                       #
  ########################################################################
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    apps = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        scriptDrv = pkgs.writeShellScriptBin "setup-wizard" ''
          #!${pkgs.runtimeShell}
          export PATH=${pkgs.pciutils}/bin:$PATH
          export REPO_ROOT="$PWD"
          exec ${pkgs.python3}/bin/python ${./scripts/setup-wizard.py} "$@"
        '';
      in {
        setup-wizard = {
          type    = "app";
          program = "${scriptDrv}/bin/setup-wizard";
        };
      });
  ########################################################################
  # 5  Return                                                             #
  ########################################################################
  in {
    nixosConfigurations = nixosCfgs;
    apps = apps;
  };
}
