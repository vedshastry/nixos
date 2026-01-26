{ config, pkgs, inputs, ... }:

{
  home.username = "ved";
  home.homeDirectory = "/home/ved";

  # Install User Packages
  home.packages = with pkgs; [
    # Core Tools
    zsh # Shell
    ripgrep fd unzip jq tree
    ranger
    lf

    # Standard progs (xinit)
    picom
    nitrogen
    dunst
    flameshot
    numlockx

    # x11 utils
    xdg-utils
    xorg.xset
    xorg.setxkbmap
    xorg.xsetroot

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
    obsidian
    obs-studio
    tor
    libreoffice
    thunar
    autorandr
    zathura
    xarchiver
    sxiv
    libnotify

  # AI
    gemini-cli-bin
    geminicommit
    claude-code
    claude-monitor

  # Themes
    gnome-tweaks
    dracula-theme           # GTK theme
    dracula-icon-theme      # Icon theme
    bibata-cursors

  ];

  # XDG Defaults
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "thunar.desktop" ];
        };
      };

  # Git Config
  programs.git = {
    enable = true;
    settings.user.name = "Ved Shastry";
    settings.user.email = "vedarshis@gmail.com";
  };

    # 1. Global Variables (Replaces exports in .zshenv/.zprofile)
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "zen";
      PDFVIEWER = "zathura";
      OPENER = "rifle";
      XDG_CURRENT_DESKTOP = "gtk"; # Tells Electron/GTK to use the GTK file chooser portal
      GTK_USE_PORTAL = "1";
    };

    # 2. Global Paths (Replaces export PATH=...)
    home.sessionPath = [
      "$HOME/scripts"
      "$HOME/ado"
      "/opt/stata18"
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

        # NixOS specifics (replacing your 'p=sudo pacman')
        update = "sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad";

        # Workflow
        lad = "ls -d .*(/)"; # Only dot-directories
        lsa = "ls -a .*(.)"; # Only dot-files
        pyenv = "source .venv/bin/activate"; # Generalized to local folder

        # Network
        won = "warp-cli connect";
        woff = "warp-cli disconnect";
      };

      # 2. MIGRATE ENVIRONMENT VARIABLES (from .zshenv)
      # Nix manages PATH automatically, but you can add USER-specific ones here.
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        BROWSER = "zen";
        PDFVIEWER = "zathura";
        OPENER = "rifle";
        # Point Stata to wherever you decide to install it (likely via nix-ld or Flatpak)
        # PATH is handled specially, see initExtra below for complex path additions
      };

      # 3. MIGRATE COMPLEX LOGIC (.zshrc + .zprofile)
      initContent = ''

        # --- Custom Prompt (Ported from your config) ---
        PROMPT='%F{white}%n%f@%F{green}%m%f %F{blue}%B%~%b%f %# '
        RPROMPT='[%F{yellow}%?%f]'

        # --- Bindkeys ---
        bindkey -v

        # --- Fix for GTK/Electron Apps in dwm ---
        # Append the gsettings-desktop-schemas path to XDG_DATA_DIRS
        export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
        
        # Ensure the portal knows we are on a GTK-based desktop (fixes the portal crash that might happen NEXT)
        export XDG_CURRENT_DESKTOP=gtk

        # --- StartX on Login (from .zprofile) ---
        if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec startx
        fi
      '';

      # 4. MIGRATE ANTIBODY PLUGINS
      # Nix manages plugins natively. No need for a txt file.
      plugins = [
        {
          # Example: if you used zsh-nvm (though you should stop using it), you'd put it here.
          # For standard plugins, just find the nixpkg version.
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
        }
        # You can add other specific plugins here if you know their names
      ];

      # 5. OH-MY-ZSH (Optional, but you had it enabled in your draft)
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "python" "sudo" ]; # Added 'sudo' for double-esc
        theme = ""; # Leave empty if you are using the custom PROMPT above
      };
    };

    ############ THEMES


    # 2. Configure GTK Declaratively
    gtk = {
      enable = true;

      theme = {
        name = "Dracula";             # Must match the folder name exactly
        package = pkgs.dracula-theme; # Tells Nix where to find it
      };

      iconTheme = {
        name = "Dracula";             # Or "Papirus-Dark", etc.
        package = pkgs.dracula-icon-theme;
      };

      font = {
        name = "Noto Sans";
        size = 10;
      };

      # 3. Handling GTK2 (The old stuff)
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      # This writes to ~/.config/gtk-2.0/gtkrc instead of cluttering ~ with .gtkrc-2.0
    };

    # 4. Mouse Cursor (Applies to X11 root window and GTK)
    home.file.".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"; # link cursor icons to home
    home.pointerCursor = {
      gtk.enable = true;
      name = "Bibata-Modern-Ice";               # Replace with your cursor name
      package = pkgs.bibata-cursors;
      size = 20;
    };

    # QT -> GTK
    qt = {
        enable = true;
        platformTheme.name = "gtk"; # Tell Qt apps to look like GTK apps
        style.name = "gtk2";
      };


  # Services
  services.blueman-applet.enable = true;
  services.syncthing = {
  enable = true;
  # This ensures the tray icon starts too
  tray.enable = true;
  };

  # Version
  home.stateVersion = "25.11";
}
