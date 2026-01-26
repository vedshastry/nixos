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

    # Standard progs (xinit)
    picom
    nitrogen
    dunst
    flameshot
    numlockx

    # x11 utils
    xorg.xset
    xorg.setxkbmap
    xorg.xsetroot

    # Tray apps
    networkmanagerapplet
    blueman
    pasystray
    solaar


    # Browsers
    inputs.zen-browser.packages."${pkgs.system}".default

    # Research / Dev
    pulsar
    neovim
    python3
    R
    qgis
    #julia

    # Apps
    keepassxc
    maestral # Dropbox client
    maestral-gui # Dropbox client (GUI)
    slack
    touchegg
    emacs
    syncthing
    obsidian
    obs-studio
    tor
    libreoffice
    thunar
    autorandr
    zathura
    xarchiver

  ];

  # Git Config
  programs.git = {
    enable = true;
    settings.user.name = "Ved Shastry";
    settings.user.email = "vedarshis@gmail.com";
  };

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
        update = "sudo nixos-rebuild switch --flake ~/nixos-config#thinkpad";

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
      initExtra = ''
        # --- Custom Prompt (Ported from your config) ---
        PROMPT='%F{white}%n%f@%F{green}%m%f %F{blue}%B%~%b%f %# '
        RPROMPT='[%F{yellow}%?%f]'

        # --- Bindkeys ---
        bindkey -v

        # --- StartX on Login (from .zprofile) ---
        if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec startx
        fi

        # --- Manual PATH additions (if absolutely necessary) ---
        # In Nix, prefer installing tools via home.packages, but if you have legacy scripts:
        export PATH=$HOME/scripts:$HOME/ado:$PATH
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

  home.stateVersion = "25.11";
}
