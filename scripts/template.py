tmpl = f"""\
{{ modules, pkgs, host, ... }}:

{{
  imports = [
    modules.universal
    modules.{"linux" if role.startswith("linux") else "darwin"}
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [ modules.kde ])
    ++ [
      ./hardware-configuration.nix
      ../../users/{user}.nix
    ];

  networking.hostName = host;
  my.isLaptop = {str(is_laptop).lower()};   # --- NEW

  time.timeZone       = "{tz}";
{override_locale}{override_extra}}}
"""