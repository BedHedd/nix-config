{
  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows     = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, nixos-hardware, ... }:

  let
    # your hosts:
    hostNames     = builtins.filter
                      (n: builtins.pathExists ./hosts/${n}/default.nix)
                      (builtins.attrNames (builtins.readDir ./hosts));

    defaultSystem = "x86_64-linux";

    modules       = import ./modules;
    mkSpecialArgs = { inherit modules home-manager plasma-manager nixos-hardware; };

    # ← move it here
    systems       = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  in
  {
    nixosConfigurations = nixpkgs.lib.genAttrs hostNames (host:
      nixpkgs.lib.nixosSystem {
        system     = defaultSystem;
        modules    = [ ./hosts/${host}/default.nix ]
                     ++ nixpkgs.lib.optionals (defaultSystem == "x86_64-linux") [ modules.kde ];
        specialArgs = mkSpecialArgs // { inherit host; };
      });

    apps = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs      = import nixpkgs { inherit system; };
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
