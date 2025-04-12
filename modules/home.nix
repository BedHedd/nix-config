{ pkgs, ... }:

{
  imports = [ 
    ./entertainment.nix 
    # ./research.nix 
    # ./work.nix 
  ];

  fonts.fontconfig.enable = true;

  xdg.enable = true;

  home = { 
    packages = with pkgs; [ 
      gnupg 

      # dictionaries
      # aspell
      # aspellDicts.en
    ];
    stateVersion = "22.05";
  };

  #nix = {
    #package = pkgs.nixUnstable;
    #settings = {
      #experimental-features = "nix-command flakes";
      #allow-import-from-derivation = true;
    #};
  #};

  programs = {
    home-manager.enable = true;
    direnv.enable = true;
#    bash = {
#      enable = true;
#      initExtra = builtins.readFile ../dotfiles/.bashrc;
#    };
#    tmux = {
#      enable = true;
#      keyMode = "vi";
#      extraConfig = builtins.readFile ../dotfiles/.tmux.conf;
#    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      # Pass configuration options directly
      extraConfig = ''
        set autoindent
        set smartindent
        filetype plugin indent on
      '';

      # Optionally, include plugins using an overlay or package reference.
      # For example, using vim-nix if it’s available as a package:
      plugins = with pkgs.vimPlugins; [ vim-nix ];
    };
    firefox = {
      enable = true;
      package = pkgs.librewolf;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        Preferences = {
          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;      
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      includes = [
        # { path = ../dotfiles/gitconfig; } # git account config for paths
        # { condition = "gitdir:iohk/"; path = ../dotfiles/gitconfig-iohk; } 
        # { condition = "gitdir:input-output-hk/"; path = ../dotfiles/gitconfig-iohk; }
        # { condition = "gitdir:IntersectMBO/"; path = ../dotfiles/gitconfig-iohk; }
        # { condition = "gitdir:cardano-foundation/"; path = ../dotfiles/gitconfig-iohk; }
        # { condition = "gitdir:circuithub/"; path = ../dotfiles/gitconfig-circuithub; }
      ];
    };
    gh = {
      enable = true;
      settings = {
        # Workaround for https://github.com/nix-community/home-manager/issues/4744
        version = 1;
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = import ../dotfiles/fish-config.nix {};
      plugins = [
        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
            sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
          };
        }
      ];
    };
    #zoxide = {
      #enable = true
    #};
#    vim = {
#      enable = true;
#      plugins = with pkgs.vimPlugins; [
#        airline
#        fugitive
#        vim-markdown
#        nerdtree
#        nerdcommenter
#        molokai
#        repeat
#        surround
#        syntastic
#      ];
#      extraConfig = builtins.readFile ../dotfiles/.vimrc;
#    };
#    zsh = {
#      enable = true;
#      prezto = {
#        enable = true;
#        # https://github.com/nix-community/home-manager/issues/2255
#        caseSensitive = true;
#        prompt.theme = "powerlevel10k";
#        pmodules = [
#          "environment"
#          "terminal"
#          "editor"
#          "history"
#          "directory"
#          "spectrum"
#          "utility"
#          "git"
#          "completion"
#          "syntax-highlighting"
#          "history-substring-search"
#          "prompt"
#        ];
#        editor.keymap = "vi";
#      };
#      initExtra = builtins.readFile ../dotfiles/.zshrc + builtins.readFile ../dotfiles/.p10k.zsh;
#    };
  };

  services = {
#    gpg-agent = {
#      enable = true;
#      # one day
#      maxCacheTtl = 86400;
#      # six hours
#      defaultCacheTtl = 21600;
#      pinentryPackage = pkgs.pinentry-qt;
#    };
  };
}
