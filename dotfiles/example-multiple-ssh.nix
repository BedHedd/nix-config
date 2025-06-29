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
    addKeysToAgent = "yes"; 

    matchBlocks = {
      "github.com-primary" = {
        hostname       = "github.com";
        user           = "git";
        identityFile   = "~/.ssh/${primaryKeyFile}";
        identitiesOnly = true;       # force this key only
      };
      "github.com-secondary" = {
        hostname       = "github.com";
        user           = "git";
        identityFile   = "~/.ssh/${secondaryKeyFile}";
        identitiesOnly = true;
      };
    };

    # optional: fix pinentry TTY when using gpg-agent
    extraConfig = ''
      Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
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