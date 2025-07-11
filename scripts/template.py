# templates for host files
tmpl = r"""
{{ modules, pkgs, host, ... }}:

{{
  imports = [
    modules.universal
    modules.{os_module}
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [ modules.kde ])
    ++ [
      ./hardware-configuration.nix
      ../../users/{user}.nix
    ];

  networking.hostName = host;
  my.isLaptop = {is_laptop};

  time.timeZone       = "{tz}";
{override_locale}{override_extra}}}
"""
