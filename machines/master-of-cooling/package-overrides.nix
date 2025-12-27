# PC-specific package overrides (CUDA, custom packages)
# Note: allowUnfree is set in common/nixpkgs.nix
{ pkgs, ... }:

{
  nixpkgs.config = {
    # cudaSupport = true;
    # rocmSupport = true;
    packageOverrides = pkgs: {
      ollama = pkgs.ollama.overrideAttrs (oldAttrs: rec {
        version = "0.13.5";
        src = pkgs.fetchFromGitHub {
          owner = "ollama";
          repo = "ollama";
          rev = "v${version}";
          hash = "sha256-4K1+GE96Uu5w1otSiP69vNDJ03tFvr78VluIEHMzFGQ=";
        };
        vendorHash = "sha256-NM0vtue0MFrAJCjmpYJ/rPEDWBxWCzBrWDb0MVOhY+Q=";
        postFixup = pkgs.lib.replaceStrings [
          ''mv "$out/bin/app" "$out/bin/.ollama-app"''
        ] [
          ''if [ -e "$out/bin/app" ]; then
             mv "$out/bin/app" "$out/bin/.ollama-app"
           fi''
        ] oldAttrs.postFixup;
      });

      ollama-rocm = pkgs.ollama-rocm.overrideAttrs (oldAttrs: rec {
        version = "0.13.5";
        src = pkgs.fetchFromGitHub {
          owner = "ollama";
          repo = "ollama";
          rev = "v${version}";
          hash = "sha256-4K1+GE96Uu5w1otSiP69vNDJ03tFvr78VluIEHMzFGQ=";
        };
        vendorHash = "sha256-NM0vtue0MFrAJCjmpYJ/rPEDWBxWCzBrWDb0MVOhY+Q=";
        postFixup = pkgs.lib.replaceStrings [
          ''mv "$out/bin/app" "$out/bin/.ollama-app"''
        ] [
          ''if [ -e "$out/bin/app" ]; then
             mv "$out/bin/app" "$out/bin/.ollama-app"
           fi''
        ] oldAttrs.postFixup;
      });

      # Override llama-cpp to latest version b6150 with CUDA support
      llama-cpp =
        (pkgs.llama-cpp.override {
          cudaSupport = false;
          rocmSupport = true;
          metalSupport = false;
          # Enable BLAS for optimized CPU layer performance (OpenBLAS)
          # This is crucial for models using split-mode or CPU offloading
          blasSupport = true;
        }).overrideAttrs
          (oldAttrs: rec {
            version = "7531";
            src = pkgs.fetchFromGitHub {
              owner = "ggml-org";
              repo = "llama.cpp";
              tag = "b${version}";
              hash = "sha256-91zqS5yUN89wVOVxv9W56bR4Bqoul9YmCl89ArNli+Y=";
              leaveDotGit = true;
              postFetch = ''
                git -C "$out" rev-parse --short HEAD > $out/COMMIT
                find "$out" -name .git -print0 | xargs -0 rm -rf
              '';
            };
            # Enable native CPU optimizations for massively better CPU performance
            # This enables AVX, AVX2, AVX-512, FMA, etc. for your specific CPU
            # NOTE: This is intentionally opposite of nixpkgs (which uses -DGGML_NATIVE=off
            # for reproducible builds). We sacrifice portability for faster CPU layers.
            cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
              "-DGGML_NATIVE=ON"
            ];

            # Disable Nix's NIX_ENFORCE_NO_NATIVE which strips -march=native flags
            # See: https://github.com/NixOS/nixpkgs/issues/357736
            # See: https://github.com/NixOS/nixpkgs/pull/377484 (intentionally contradicts this)
            preConfigure = ''
              export NIX_ENFORCE_NO_NATIVE=0
              ${oldAttrs.preConfigure or ""}
            '';
          });

      # llama-swap from GitHub releases
      llama-swap = pkgs.runCommand "llama-swap" { } ''
        mkdir -p $out/bin
        tar -xzf ${
          pkgs.fetchurl {
            url = "https://github.com/mostlygeek/llama-swap/releases/download/v178/llama-swap_178_linux_amd64.tar.gz";
            hash = "sha256-WhoGaS+m+2Ne+7U5JVvj1Fr5n3xB3ccsTe93slSAhFw=";
          }
        } -C $out/bin
        chmod +x $out/bin/llama-swap
      '';
    };
  };
  environment.variables.LLAMA_CACHE = "/mnt/sda1/Documents/ollama-models/llama-cpp-cache";
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    extraGroups = [ "llm" ];
  };
  users.groups.ollama = {};

  users.users.llama-cpp = {
    isSystemUser = true;
    group = "llama-cpp";
    extraGroups = [ "llm" ];
  };
  users.groups.llama-cpp = {};

  users.groups.llm = {};
  users.users.bedhedd.extraGroups = [ "llm" ]; 

  systemd.tmpfiles.rules = [
    # shared base dir (setgid so new files inherit group)
    "d /mnt/sda1/Documents/ollama-models 2775 ollama llm -"
    # cache dir
    "d /mnt/sda1/Documents/ollama-models/llama-cpp-cache 2775 llama-cpp llm -"
  ];

  systemd.services.llama-cpp.environment.LLAMA_CACHE =
    "/mnt/sda1/Documents/ollama-models/llama-cpp-cache";

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      OLLAMA_MODELS = "/mnt/sda1/Documents/ollama-models";  # <-- custom model dir
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
    models  = "/mnt/sda1/Documents/ollama-models";  # <-- custom model dir
  };
}