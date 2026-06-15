{ config, pkgs, inputs, ... }:

{
  home.username = "ved";
  home.homeDirectory = "/home/ved";

  # Install User Packages
  home.packages = with pkgs; [
    # Core Tools
    zsh # Shell
    ripgrep fd 
    unzip jq tree p7zip unrar atool
    ranger
    lf

    # Standard progs (xinit)
    picom
    nitrogen
    dunst
    flameshot
    ksnip
    numlockx

    # x11 utils
    xdg-utils
    xset
    setxkbmap
    xsetroot

    # Tray apps
    networkmanagerapplet
    blueman
    pasystray
    solaar

    # Browsers
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    google-chrome
    librewolf


    # Research / Dev
    texlive.combined.scheme-full
    texlab # language server for neovim
    pulsar # inputs.pulsar-flake.packages.${pkgs.system}.default
    neovim
    R
    qgis
    julia-bin
    # Python with default packages
    (python3.withPackages (ps: with ps; [
      pandas
      numpy
      matplotlib
      ipykernel
    ]))
    gimp

    # Apps
    keepassxc
    maestral # Dropbox client
    maestral-gui # Dropbox client (GUI)
    slack
    touchegg
    emacs
    electrum
    monero-gui
    obsidian
    obs-studio
    tor
    tor-browser
    libreoffice-fresh
    thunar
    autorandr
    zathura
    xarchiver
    sxiv
    mpv
    libnotify

  # AI
    gemini-cli-bin
    geminicommit
    llama-cpp
    goose-cli
    inputs.claude-code-nix.packages."${pkgs.stdenv.hostPlatform.system}".claude-code

  # Themes
    gnome-tweaks
    dracula-theme           # GTK theme
    dracula-icon-theme      # Icon theme
    bibata-cursors
    gnome-themes-extra      # Other GNOME themes
    adwaita-icon-theme
  ];

  # XDG Defaults
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "text/x-lua" = "nvim.desktop";
      "application/x-lua" = "nvim.desktop";
      
      # Catch-alls for "random/unknown" files:
      "application/octet-stream" = "nvim.desktop"; # Unrecognized/binary files
      "application/x-zerosize" = "nvim.desktop";   # Completely empty files

      # Browser
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };

  # Git Config
  programs.git = {
    enable = true;
    settings.user.name = "Ved Shastry";
    settings.user.email = "vedarshis@gmail.com";
  };

  # Global Variables (Replaces exports in .zshenv/.zprofile)
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "zen-beta";
    PDFVIEWER = "zathura";
    OPENER = "rifle";
    XDG_CURRENT_DESKTOP = "gtk"; # Tells Electron/GTK to use the GTK file chooser portal
    GTK_USE_PORTAL = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice"; # Cursor theme
    XCURSOR_SIZE = "20"; # Cursor size
  };

  # Global Paths (Replaces export PATH=...)
  home.sessionPath = [
    "$HOME/scripts"
    "$HOME/ado"
    "/opt/stata18"
    "$HOME/.local/bin"
  ];

  # Zsh config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 1. MIGRATE ALIASES
    shellAliases = {
      # System
      ll = "ls -l";
      reboot = "systemctl reboot"; # Use systemctl instead of /sbin/reboot
      slp = "systemctl suspend";

      # Editors
      vim = "nvim";
      v = "nvim";
      vp = "nvim -p";
      sv = "sudo nvim";
      smp = "stata-mp";
      xmp = "xstata-mp";

      # NixOS specifics (replacing your 'p=sudo pacman')
      update = "sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad";
      sysup = "nix flake update --flake ~/repos/nixos && sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad";

      # Workflow
      lad = "ls -d .*(/)"; # Only dot-directories
      lsa = "ls -a .*(.)"; # Only dot-files
      pyenv = "source .venv/bin/activate"; # Generalized to local folder

      # Network
      won = "warp-cli connect";
      woff = "warp-cli disconnect";
    };

    # 2. MIGRATE ENVIRONMENT VARIABLES (from .zshenv)
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "zen-beta";
      PDFVIEWER = "zathura";
      OPENER = "rifle";

      # AI Agents
      OPENAI_BASE_URL="http://127.0.0.1:8080/v1";
      OPENAI_API_KEY="sk-local";
    };

    # 3. MIGRATE COMPLEX LOGIC (.zshrc + .zprofile)
    initContent = ''
      # --- Custom Prompt (Ported from your config) ---
      PROMPT='%F{white}%n%f@%F{green}%m%f %F{blue}%B%~%b%f %# '
      RPROMPT='[%F{yellow}%?%f]'

      # --- Bindkeys ---
      bindkey -v

      # --- Fix for GTK/Electron Apps in dwm ---
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
      
      export XDG_CURRENT_DESKTOP=gtk

      # --- StartX on Login (from .zprofile) ---
      if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        exec startx
      fi
    '';

    # 4. MIGRATE ANTIBODY PLUGINS
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
    ];

    # 5. OH-MY-ZSH
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "python" "sudo" ];
      theme = ""; 
    };
  };

  ############ THEMES

  # Xresources
  xresources.properties = {
    "*.foreground" = "#e6e1dc";
    "*.background" = "#2b2b2b";
    "*.cursorColor" = "#e6e1dc";

    "*.color0" = "#2b2b2b";
    "*.color8" = "#5a647e";

    "*.color1" = "#da4939";
    "*.color9" = "#da4939";

    "*.color2" = "#a5c261";
    "*.color10" = "#a5c261";

    "*.color3" = "#ffc66d";
    "*.color11" = "#ffc66d";

    "*.color4" = "#6d9cbe";
    "*.color12" = "#6d9cbe";

    "*.color5" = "#b6b3eb";
    "*.color13" = "#b6b3eb";

    "*.color6" = "#519f50";
    "*.color14" = "#519f50";

    "*.color7" = "#e6e1dc";
    "*.color15" = "#f9f7f3";
  };

  # Configure GTK Declaratively
  gtk = {
    enable = true;

    theme = {
      name = "Dracula";             
      package = pkgs.dracula-theme; 
    };

    iconTheme = {
      name = "Dracula";             
      package = pkgs.dracula-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 10;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  # Mouse Cursor
  home.file.".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"; 
  home.pointerCursor = {
    gtk.enable = true;      
    x11.enable = true;      
    name = "Bibata-Modern-Ice";               
    package = pkgs.bibata-cursors;
    size = 20;
  };

  gtk.gtk4.theme = config.gtk.theme; 

  # QT -> GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk"; 
    style.name = "gtk2";
  };

  # Services
  services.blueman-applet.enable = true;
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  # Run Llama daemon
  systemd.user.services.llama-server = {
    Unit = {
      Description = "llama.cpp Router Mode Server";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.llama-cpp}/bin/llama-server --models-dir %h/ai --port 8080 -c 32768 --models-max 1";
      Restart = "always";
      RestartSec = "10";
      Environment = [
        "HSA_OVERRIDE_GFX_VERSION=11.0.2"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Version
  home.stateVersion = "25.11";
}
