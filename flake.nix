{
  description = "bedHedd flakes";

  inputs = {
    nixpkgs  = {
       url = "github:nixos/nixpkgs/nixos-unstable";
     };

     home-manager = {
       url = "github:nix-community/home-manager";
     };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
  
    nixosConfigurations =
      let
        revModule =
          {
              # Let 'nixos-version --json' know about the Git revision
              # of this flake.
              system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          };
        localNixpkgsModule =
          {
              # For compatibility with other things, puts nixpkgs into NIX_PATH
              environment.etc.nixpkgs.source = nixpkgs;
              nix.nixPath = ["nixpkgs=/etc/nixpkgs"];
          };
      in {
      jade-tiger = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          (import ./machines/jade-tiger/configuration.nix)
          # (import ./profiles/dev.nix)
          revModule
          localNixpkgsModule
        ];
        specialArgs = { inherit nixos-hardware home-manager; };
      };
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    #nixosConfigurations.jade-tiger = nixpkgs.lib.nixosSystem {
      #system = "x86_64-linux";
      #specialArgs = {inherit inputs;};
      #modules = [
      #  ./machines/configuration.nix
        # inputs.home-manager.nixosModules.default
      #];
    };
  };
}
