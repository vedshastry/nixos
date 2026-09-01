{ config, pkgs, inputs, ... }:

let
  # llama.cpp built with the Vulkan backend so the integrated Radeon 780M
  # (RADV PHOENIX) is actually used for inference instead of CPU-only BLAS.
  llama-cpp-vulkan = pkgs.llama-cpp.override { vulkanSupport = true; };

  # Flameshot pinned to nixos-25.05 (12.1.0, Qt5). Unstable's 14.0.0 (Qt6)
  # routes all captures through xdg-desktop-portal, which has no working
  # Screenshot backend under bare dwm -> "portal timed out after 30 seconds".
  # The 12.x build grabs X11 directly, so the tray icon + Print shortcut work.
  flameshot-pinned =
    inputs.nixpkgs-flameshot.legacyPackages.${pkgs.stdenv.hostPlatform.system}.flameshot;

  # QGIS pinned to nixos-25.05 (reusing the stable pin above). On unstable,
  # qgis pulls pdal, which fails to build against unstable's newer GDAL
  # (GetMetadata() now returns CSLConstList) and needed a -fpermissive
  # override -> a from-source rebuild of pdal AND qgis on every nixpkgs bump.
  # The 25.05 stable channel predates that GDAL change, so pdal/qgis build
  # cleanly there and come straight from cache.nixos.org -- no override, no
  # local compilation. Revisit in a few months if a newer qgis is needed.
  qgis-pinned =
    inputs.nixpkgs-flameshot.legacyPackages.${pkgs.stdenv.hostPlatform.system}.qgis;

  # CLIProxyAPI: local proxy that re-serves CLI OAuth logins (ChatGPT/Codex,
  # Claude, Gemini) as OpenAI-/Anthropic-compatible HTTP APIs on :8317.
  # Not in nixpkgs; packaged locally in ./pkgs.
  cli-proxy-api = pkgs.callPackage ./pkgs/cli-proxy-api.nix { };

  # - Fix GTK2 app theming
    # gtk-engine-murrine was removed from nixpkgs (GTK2 purge), 
    # but the gtk2 library still exists.
    # Rebuild murrine from the last GNOME release and set GTK_PATH
  gtk-engine-murrine = pkgs.stdenv.mkDerivation rec {
    pname = "gtk-engine-murrine";
    version = "0.98.2";
    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/murrine/0.98/murrine-${version}.tar.xz";
      sha256 = "129cs5bqw23i76h3nmc29c9mqkm9460iwc8vkl7hs4xr07h8mip9";
    };
    nativeBuildInputs = with pkgs; [ pkg-config intltool ];
    buildInputs = [ pkgs.gtk2 ];
    # GCC >= 14 makes implicit function declarations a hard error; murrine's
    # 2012-era C relies on them (murrine_widget_is_ltr etc. lack prototypes).
    env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  # dracula-theme was removed from nixpkgs because it depended on
  # gtk-engine-murrine (see above). Build it directly from the upstream
  # flake input instead, including gtk-2.0 for xstata.
  dracula-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "dracula-theme";
    version = "unstable-2026-07-31";
    src = inputs.dracula-gtk-theme;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes/Dracula
      cp -a {assets,gnome-shell,gtk-2.0,gtk-3.0,gtk-3.20,gtk-4.0,index.theme,metacity-1,xfwm4} $out/share/themes/Dracula
      runHook postInstall
    '';
  };
in
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
    feh                # wallpaper; nitrogen removed from nixpkgs (gtk2)
    gtk-engine-murrine # GTK2 theme engine 
    dunst
    flameshot-pinned   # 12.1.0 (Qt5) pin
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
    texliveFull
    texlab # language server for neovim
    pulsar # inputs.pulsar-flake.packages.${pkgs.system}.default
    neovim
    R
    qgis-pinned   # nixos-25.05 pin
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
    pandoc
    xarchiver
    sxiv
    mpv
    libnotify

    # Agents
    llama-cpp-vulkan   # Vulkan-enabled llama.cpp (uses the 780M iGPU)
    goose-cli
    inputs.claude-code-nix.packages."${pkgs.stdenv.hostPlatform.system}".claude-code # Claude code flake
    inputs.codex-cli-nix.packages."${pkgs.stdenv.hostPlatform.system}".default # Codex CLI flake
    #inputs.antigravity-nix.packages."${pkgs.stdenv.hostPlatform.system}".antigravity # Antigravity flake
    cli-proxy-api # CLIProxyAPI: serves ChatGPT/Codex OAuth as an Anthropic-compatible API
    mcp-nixos # MCP for nixos

  # Themes
    gnome-tweaks
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
    # Lets GTK2 apps (xstata) find the murrine engine the Dracula theme uses
    GTK_PATH = "${gtk-engine-murrine}/lib/gtk-2.0";
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

      # Claude Code driving GPT models through the local CLIProxyAPI (:8317),
      # which re-serves the ChatGPT Plus OAuth login as an Anthropic API.
      # ANTHROPIC_* are scoped to this command only -- never exported. The
      # shared secret lives in ~/.cli-proxy-api/token (chmod 600, outside this
      # repo, which is public on GitHub) and is read at invocation time.
      claudex = "ANTHROPIC_BASE_URL=http://127.0.0.1:8317 "
        + "ANTHROPIC_AUTH_TOKEN=\"$(cat ~/.cli-proxy-api/token)\" "
        + "CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol "
        + "CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 "
        + "CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 "
        + "ENABLE_TOOL_SEARCH=false "
        + "claude --model gpt-5.6-sol";
    };

    # 2. MIGRATE ENVIRONMENT VARIABLES (from .zshenv)
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "zen-beta";
      PDFVIEWER = "zathura";
      OPENER = "rifle";

      # AI Agents
      # NOTE: OPENAI_BASE_URL / OPENAI_API_KEY are deliberately NOT exported
      # globally. Codex CLI honours them and would silently route a real
      # ChatGPT session at the local llama.cpp server. Use the `local-ai`
      # shell function below to scope them to a single command.
    };

    # 3. MIGRATE COMPLEX LOGIC (.zshrc + .zprofile)
    initContent = ''
      # --- Custom Prompt (Ported from your config) ---
      PROMPT='%F{white}%n%f@%F{green}%m%f %F{blue}%B%~%b%f %# '
      RPROMPT='[%F{yellow}%?%f]'

      # --- Bindkeys ---
      bindkey -v

      # --- Local llama.cpp inference (scoped, not global) ---
      # Usage: local-ai <command ...>   e.g. `local-ai aichat "hi"`
      local-ai() {
        OPENAI_BASE_URL="http://127.0.0.1:8080/v1" \
        OPENAI_API_KEY="sk-local" \
        "$@"
      }

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
      package = dracula-theme;
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
    enable = true;
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
    platformTheme.name = "gtk2";
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
      # Default to CPU (no -ngl): on the 780M, Vulkan offload gives ~no generation
      # speedup (shared RAM bus) yet costs a 5+ min first-run shader compile.
      # Benchmarked: OLMoE (1B active) hits ~34 tok/s gen / ~200 tok/s prompt on CPU.
      # To experiment with GPU offload on a big dense model, add: -ngl 99
      ExecStart = "${llama-cpp-vulkan}/bin/llama-server --models-dir %h/ai --port 8080 -c 32768 --models-max 1 --flash-attn on";
      Restart = "always";
      RestartSec = "10";
      Environment = [
        # Persist compiled Vulkan shaders, so any manual GPU run pays compile cost once.
        "MESA_SHADER_CACHE_DIR=%h/.cache/mesa_shader_cache"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # CLIProxyAPI: serves the ChatGPT/Codex OAuth login as an Anthropic-compatible
  # API on 127.0.0.1:8317, so the `claudex` alias can run Claude Code on GPT
  # models. Config and credentials live in ~/.cli-proxy-api (outside this repo).
  systemd.user.services.cli-proxy-api = {
    Unit = {
      Description = "CLIProxyAPI - local OAuth-to-API proxy for coding harnesses";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${cli-proxy-api}/bin/cli-proxy-api -config %h/.cli-proxy-api/config.yaml";
      Restart = "always";
      RestartSec = "10";
      # OPENAI_* are unset defensively: if they ever leak into the user session
      # again, the proxy must not inherit a pointer to the local llama server.
      UnsetEnvironment = [ "OPENAI_API_KEY" "OPENAI_BASE_URL" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Version
  home.stateVersion = "25.11";
}
