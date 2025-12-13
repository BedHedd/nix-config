{ pkgs, ... }:

{
  imports = [ 
    # ./entertainment.nix
    # ./research.nix 
    # ./work.nix 
  ];

  fonts.fontconfig.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  home = { 
    packages = with pkgs; [ 
      # handy cli packages
      gnupg
      keychain
      zoxide
      fzf
      tree
      fastfetch
      tealdeer
      clamav

      # rustdesk

      # dictionaries
      # aspell
      # aspellDicts.en

      # system packages
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      wl-clipboard
      xclip
      usbutils
      kdePackages.kdeconnect-kde
      kdePackages.kcalc
    ];
    stateVersion = "25.05";
  };

  #nix = {
    #package = pkgs.nixUnstable;
    #settings = {
      #experimental-features = "nix-command flakes";
      #allow-import-from-derivation = true;
    #};
  #};
  home.shell.enableFishIntegration = true;

  programs = {
    home-manager.enable = true;
    direnv.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = import ../dotfiles/fish-config.nix { inherit pkgs; };
      plugins = [
        #{ name = "grc"; src = pkgs.fishPlugins.grc.src; }
        #{
        #  name = "z";
        #  src = pkgs.fetchFromGitHub {
        #    owner = "jethrokuan";
        #    repo = "z";
        #    rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
        #    sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        #  };
        #}
      ];
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = ["--cmd cd | source"];
    };
    bash = {
      enable = true;
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };   
#    tmux = {
#      enable = true;
#      keyMode = "vi";
#      extraConfig = builtins.readFile ../dotfiles/.tmux.conf;
#    };
    neovim = {
      enable = true;
      defaultEditor = true;
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
    vscode = {
      enable  = true;                       # create the wrapper script and dirs
      package = pkgs.vscodium;              # use VSCodium instead of Microsoft VS Code
      
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-toolsai.jupyter
          jnoortheen.nix-ide
          asvetliakov.vscode-neovim
        ];
      
        userSettings = {
          # disable smooth scrolling
          "editor.smoothScrolling" = false;
          "notebook.lineNumbers"= "on";          
        };
      };
    };
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        settings = {
          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;      
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          # do not clear cookies and logins
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.siteSettings" = false;
          "network.cookie.lifetimePolicy" = 0; # 0 = accept normally
          "privacy.sanitize.sanitizeOnShutdown" = false;
        };
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
    librewolf = {
      enable = true;
      package = pkgs.librewolf;
      settings = {
          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;      
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          # do not clear cookies and logins
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.siteSettings" = false;
          "network.cookie.lifetimePolicy" = 0; # 0 = accept normally
          "privacy.sanitize.sanitizeOnShutdown" = false;
        };
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
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
      # was: pkgs.gitAndTools.gitFull
      package = pkgs.gitFull;     # or pkgs.git if you don't need the extras
      includes = [
        # { path = ../dotfiles/gitconfig; }
        # { condition = "gitdir:iohk/"; path = ../dotfiles/gitconfig-iohk; }
        # ...
      ];
      # optional niceties:
      # lfs.enable = true;          # replaces separate git-lfs install
      # delta.enable = true;        # nicer diffs
  };
    gh = {
      enable = true;
      settings = {
        # Workaround for https://github.com/nix-community/home-manager/issues/4744
        version = 1;
      };
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
  #  gpg-agent = {
  #    enable = true;
  #    enableSshSupport = true;
  #    # one day
  #    maxCacheTtl = 86400;
  #    # six hours
  #    defaultCacheTtl = 21600;
  #    pinentry.package  = pkgs.pinentry-qt;
  #  };
  };
}
