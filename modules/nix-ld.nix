# modules/nix-ld.nix
{ pkgs, ... }: {
  programs.nix-ld.enable = true;

  # Optional: extra libs for closed-source binaries
  # programs.nix-ld.libraries = with pkgs; [ zlib openssl ];
}
