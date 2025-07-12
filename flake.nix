{
  ########################################################################
  # 1  Inputs                                                             #
  ########################################################################
  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows     = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  ########################################################################
  # 2  Outputs                                                            #
  ########################################################################
  outputs = { self, nixpkgs, home-manager, plasma-manager, nixos-hardware, ... }:

  let
    # a) find any sub-folder under ./hosts that has a default.nix
    hostNames =
      builtins.filter
        (name: builtins.pathExists ./hosts/${name}/default.nix)
        (builtins.attrNames (builtins.readDir ./hosts));

    # b) your default system for all hosts
    defaultSystem = "x86_64-linux";

    # c) your shared modules set (universal, linux, kde, etc.)
    modules    = import ./modules;

    # d) the four things you want every host to see
    mkSpecialArgs = {
      inherit modules home-manager plasma-manager nixos-hardware;
    };
  in
  {
    ########################################################################
    # 3  NixOS configurations                                               #
    ########################################################################
    nixosConfigurations =
      nixpkgs.lib.genAttrs hostNames (host:
        nixpkgs.lib.nixosSystem {
          system  = defaultSystem;

          # each host just points at its own default.nix, plus `modules.kde` on Linux
          modules =
            [ ./hosts/${host}/default.nix ]
            ++ nixpkgs.lib.optionals (defaultSystem == "x86_64-linux") [ modules.kde ];

          # inject your four flakes + the host name itself
          specialArgs = mkSpecialArgs // { inherit host; };
        });

    ########################################################################
    # 4  setup-wizard app                                                    #
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
  };
}
