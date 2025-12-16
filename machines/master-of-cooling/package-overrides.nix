# PC-specific package overrides (CUDA, custom packages)
{ pkgs, inputs, ... }:

{
  nixpkgs.config = {
    packageOverrides = pkgs: let
      mkOllamaFromGitHub = base: base.overrideAttrs (oldAttrs: {
        # flake-pinned source (no rev/hash here)
        src = inputs.ollama-src;

        # keep your postFixup change
        postFixup = pkgs.lib.replaceStrings
          [ ''mv "$out/bin/app" "$out/bin/.ollama-app"'' ]
          [ ''if [ -e "$out/bin/app" ]; then
                 mv "$out/bin/app" "$out/bin/.ollama-app"
               fi'' ]
          (oldAttrs.postFixup or "");

        # IMPORTANT: vendorHash is still required for Go deps and may change
        # Keep it here; update only when Nix tells you the new one.
        vendorHash = oldAttrs.vendorHash or null;
      });
    in {
      # CPU ollama (flake-pinned)
      ollama = mkOllamaFromGitHub pkgs.ollama;

      # ROCm ollama (flake-pinned)
      ollama-rocm = mkOllamaFromGitHub pkgs.ollama-rocm;

      # llama.cpp (flake-pinned) + keep leaveDotGit/postFetch + native flags
      llama-cpp =
        (pkgs.llama-cpp.override {
          cudaSupport  = false;
          rocmSupport  = true;
          metalSupport = false;
          blasSupport  = true;
        }).overrideAttrs (oldAttrs: {
          src = inputs.llamacpp-src;

          # keep commit stamping + stripping .git (your postFetch behavior)
          postUnpack = (oldAttrs.postUnpack or "") + ''
            if [ -d source/.git ]; then
              git -C source rev-parse --short HEAD > source/COMMIT
              find source -name .git -print0 | xargs -0 rm -rf
            fi
          '';

          cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
            "-DGGML_NATIVE=ON"
          ];

          preConfigure = ''
            export NIX_ENFORCE_NO_NATIVE=0
            ${oldAttrs.preConfigure or ""}
          '';
        });

      llama-swap = pkgs.runCommand "llama-swap" { } ''
        mkdir -p $out/bin
        tar -xzf ${
          pkgs.fetchurl {
            url = "https://github.com/mostlygeek/llama-swap/releases/download/v175/llama-swap_175_linux_amd64.tar.gz";
            hash = "sha256-zeyVz0ldMxV4HKK+u5TtAozfRI6IJmeBo92IJTgkGrQ=";
          }
        } -C $out/bin
        chmod +x $out/bin/llama-swap
      '';
    };
  };

  # (rest of your config unchanged)
  services.ollama = {
    enable = true;
    
    # pick the backend by package
    package = pkgs.ollama-rocm;

    models = "/mnt/sda1/Documents/ollama-models";
    environmentVariables = {
      OLLAMA_MODELS = "/mnt/sda1/Documents/ollama-models";
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
  };

}
