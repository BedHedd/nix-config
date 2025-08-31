# dotfiles/multiple-ssh.nix
{ config, pkgs, lib, ... }:

let
  primaryFolder   = "folder_for_account_1";
  secondaryFolder = "folder_for_account_2";
  primaryKeyFile      = "filename_for_account_1";
  secondaryKeyFile    = "filename_for_account_2";
in
{
  # ──────────────────────────────────────────────────────────────────────────
  # 1.  OpenSSH config (still needed for Host aliases)
  # ──────────────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;

    matchBlocks = {
      # If you want it on for *all* hosts, add this catch-all first:
      "*" = {
        addKeysToAgent = "yes";   # valid values: "yes" | "no" | "confirm" | "ask"
      };

      "github.com-primary" = {
        hostname       = "github.com";
        user           = "git";
        identityFile   = "~/.ssh/${primaryKeyFile}";
        identitiesOnly = true;
        # addKeysToAgent inherited from "*" above; you can override per-host if needed
      };

      "github.com-secondary" = {
        hostname       = "github.com";
        user           = "git";
        identityFile   = "~/.ssh/${secondaryKeyFile}";
        identitiesOnly = true;
        # addKeysToAgent inherited from "*" above
      };
    };

    # Optional: keep your pinentry TTY refresh; this is verbatim ssh_config text
    extraConfig = ''
      Match exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
    '';
  };

  # ──────────────────────────────────────────────────────────────────────────
  # 2.  Keychain → one shared ssh-agent per login session
  # ──────────────────────────────────────────────────────────────────────────
  programs.keychain = {
    enable                = true;
    agents                = [ "ssh" ];      # also "gpg" if you like
    keys                  = [
      # "${primaryKeyFile}"
      # "${secondaryKeyFile}"
    ];
    extraFlags = [ "--noask" "--quiet" ];
    enableFishIntegration = true;          # writes eval-line to config.fish
    # For Bash/Z-sh, use enableBashIntegration / enableZshIntegration.
  };

  # ──────────────────────────────────────────────────────────────────────────
  # 3.  Git conditional includes for per-folder identities
  # ──────────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    includes = [
      {
        condition = "gitdir:*/${primaryFolder}/";
        contents = {
          user.email = "set@youremail.com";
          url."git@github.com-primary:".insteadOf = [
            "https://github.com/"
            "git@github.com:"
          ];
        };
      }
      {
        condition = "gitdir:*/${secondaryFolder}/";
        contents = {
          user.name = "github_username";
          user.email = "set@yourotheremail.com";
          url."git@github.com-secondary:".insteadOf = [
            "https://github.com/"
            "git@github.com:"
          ];
        };
      }
    ];
  };

  # ──────────────────────────────────────────────────────────────────────────
  # 4.  (Optional) gpg-agent with SSH support for GUI pass-phrase caching
  # ──────────────────────────────────────────────────────────────────────────
  services.gpg-agent = {
    enable = true;
     enableSshSupport = true;
     # one day
     maxCacheTtl = 86400;
     # six hours
     defaultCacheTtl = 21600;
     pinentry.package  = pkgs.pinentry-qt;
  };
}