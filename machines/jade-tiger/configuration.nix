# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, home-manager, plasma-manager, ... }:

{
  imports =
    [
      ../../modules/kde.nix
      ../../modules/steamdeck-plasma-system.nix
      nixos-hardware.nixosModules.common-gpu-amd
      nixos-hardware.nixosModules.gigabyte-b550
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager
      ./users.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  boot.kernelParams = [ 
    # "video=DP-1:3840x2160@60"
    "video=DP-2:3840x2160@60"
    #"video=DP-3:3840x2160@60"
    #"video=HDMI-A-1:2560x1440@59.95"
  ];

  services.udev.extraRules = ''
  # Disable wake for every AMD PCIe bridge
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{class}=="0x0604*", \
    ATTR{power/wakeup}="disabled"

  # Disable wake for AMD xHCI controllers
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{class}=="0x0c0330", \
    ATTR{power/wakeup}="disabled"

  # Disable wake for Realtek LAN on Gigabyte boards
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10ec", ATTR{device}=="0x8168", \
    ATTR{power/wakeup}="disabled"
'';

# # ── Disable every *enabled* ACPI wake device right after boot ────────────────
# systemd.services.disable-acpi-wakeups = {
#   description = "Turn off all ACPI devices that are wake-capable by default";
#   wantedBy    = [ "multi-user.target" ];
#   after       = [ "local-fs.target" ];
#
#   serviceConfig = {
#     Type = "oneshot";
#     ExecStart = pkgs.writeShellScript "disable-acpi-wakeups" ''
#       #!${pkgs.bash}/bin/bash
#       for dev in $("${pkgs.gawk}/bin/awk" '/\*enabled/ {print $1}' /proc/acpi/wakeup); do
#         echo "disabling $dev"
#         echo "$dev" > /proc/acpi/wakeup
#       done
#     '';
#     StandardOutput = "journal";
#   };
# };
#
  networking.hostName = "jade-tiger"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "us";
  #  variant = "";
  #};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    wl-clipboard
    xclip
  ];
  # Some programs need SUID wrappers, can be configured further or are:
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


  # Home‑Manager setup for plasma‑manager

  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  home-manager.sharedModules = [
    plasma-manager.homeManagerModules."plasma-manager"
  ];

  home-manager.users.admin = import ./home.nix {
    inherit pkgs plasma-manager;
  };

  users.extraUsers.admin = {
    isNormalUser = true;
    home = "/home/admin";
    extraGroups = [ "wheel" ];
};
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?


}
