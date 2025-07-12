# templates for host files
tmpl = r"""{{ config, modules, pkgs, host, home-manager, nixos-hardware, ... }}:

{{
  imports = [
    modules.universal
    modules.{os_module}
    {gpu_import}
    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../users/{user}.nix
    ];

  networking.hostName  = host;
  my.isLaptop          = {is_laptop};

  time.timeZone        = "{tz}";
{override_locale}{override_extra}

  system.stateVersion  = "{state_version}";
}}
"""
