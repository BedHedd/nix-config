{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waydroid
    uxplay
    linuxKernel.packages.linux_zen.xone
  ];
}
