{ lib, config, pkgs, ... }:

let
  cfg = config.programs.rocksmith;

  # 1. Fetch a pinned tarball of the nixos-rocksmith repo
  rocksmithSrc = builtins.fetchTarball {
    url = "https://github.com/re1n0/nixos-rocksmith/archive/master.tar.gz";
    # This is the hash Nix printed:
    sha256 = "0fkbjxxvp2amcgm6zm2vnygx4avzc1sarashkyksb07pbxcmbhfw";
  };

  # 2. Bring in flake-compat (pinned, with its sha256)
  flakeCompatSrc = builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/99f1c2157fba4bfe6211a321fd0ee43199025dbf.tar.gz";
    sha256 = "0x2jn3vrawwv9xp15674wjz9pixwjyj3j771izayl962zziivbx2";
  };

  # 3. Use flake-compat to evaluate nixos-rocksmith's flake outputs
  #    This is equivalent to what their own default.nix does.
  flakeCompat = import flakeCompatSrc { src = rocksmithSrc; };

  # 4. Upstream NixOS module from the flake outputs
  rocksmithUpstreamModule = flakeCompat.defaultNix.nixosModules.default;
in
{
  #### Options ###############################################################

  options.programs.rocksmith = {
    enable = lib.mkEnableOption "Rocksmith 2014 setup via nixos-rocksmith";

    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        User account that will play Rocksmith.
        If set, this user is added to the "audio" and "rtkit" groups.
      '';
    };
  };

  #### Imports ###############################################################

  imports = [
    rocksmithUpstreamModule
  ];

  #### Config ################################################################

  config = lib.mkIf cfg.enable {
    # Enable Steam Rocksmith patch when our toggle is on
    programs.steam = {
      rocksmithPatch.enable = true;
    };

    # Optional: add the Rocksmith user to audio/rtkit
    users.users = lib.mkIf (cfg.username != null) {
      "${cfg.username}".extraGroups = [ "audio" "rtkit" ];
    };
  };
}
