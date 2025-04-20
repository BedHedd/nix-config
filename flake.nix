{
  inputs = {
    nixpkgs  = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # make sure it uses the same nixpkgs:
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      # point it at the same nixpkgs and home‑manager:
      inputs.nixpkgs.follows     = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, plasma-manager, ... }:
  let
    revModule = {
      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
    };

    localNixpkgsModule = {
      environment.etc.nixpkgs.source = nixpkgs;
      nix.nixPath                = [ "nixpkgs=/etc/nixpkgs" ];
    };
  in
  {
    nixosConfigurations.jade-tiger = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        (import ./machines/jade-tiger/configuration.nix)
        revModule
        localNixpkgsModule

        # ← pull in Home‑Manager as a NixOS module:
        home-manager.nixosModules.home-manager
      ];

      # expose both home-manager and plasma-manager into your
      # machine’s specialArgs so that configuration.nix can see them:
      specialArgs = { inherit nixos-hardware home-manager plasma-manager; };
    };
  };
}

