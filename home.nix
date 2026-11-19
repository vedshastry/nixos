{ config, pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Vulkan-enabled llama.cpp for the Radeon 780M iGPU.
  llama-cpp-vulkan = pkgs.llama-cpp.override { vulkanSupport = true; };

  # Pinned to nixos-25.05: unstable's flameshot 14 (Qt6) requires an xdg-desktop-portal
  # Screenshot backend (absent in dwm), and unstable's qgis/pdal breaks on newer GDAL.
  flameshot-pinned = inputs.nixpkgs-flameshot.legacyPackages.${system}.flameshot;
  qgis-pinned = inputs.nixpkgs-flameshot.legacyPackages.${system}.qgis;

  # Local OAuth-to-API proxy (:8317) packaged in ./pkgs.
  cli-proxy-api = pkgs.callPackage ./pkgs/cli-proxy-api.nix { };

  # Rebuilt from GNOME sources after nixpkgs' GTK2 purge (needed for Dracula GTK2 / xstata).
  gtk-engine-murrine = pkgs.stdenv.mkDerivation rec {
    pname = "gtk-engine-murrine";
    version = "0.98.2";
    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/murrine/0.98/murrine-${version}.tar.xz";
      sha256 = "129cs5bqw23i76h3nmc29c9mqkm9460iwc8vkl7hs4xr07h8mip9";
    };
    nativeBuildInputs = with pkgs; [ pkg-config intltool ];
    buildInputs = [ pkgs.gtk2 ];
    env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration"; # GCC >= 14
  };

  # Built from flake input after nixpkgs removed dracula-theme.
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

  # --- Packages ---
  home.packages = with pkgs; [
    # Shell & CLI
    zsh
    unzip jq tree p7zip unrar atool
    lf

    # X11 & Desktop
    picom
    feh
    gtk-engine-murrine
    dunst
    flameshot-pinned
    ksnip
    numlockx
    xdg-utils
    xset
    setxkbmap
    xsetroot

    # Tray
    networkmanagerapplet
    blueman
    pasystray
    solaar

    # Browsers & Comms
    inputs.zen-browser.packages.${system}.default
    google-chrome
    librewolf
    zoom-us
    slack

    # Research & Dev
    texliveFull
    texlab
    pulsar
    R
    qgis-pinned
    julia-bin
    (python3.withPackages (ps: with ps; [
      pandas
      numpy
      matplotlib
      ipykernel
    ]))
    gimp

    # Apps
    keepassxc
    maestral
    maestral-gui
    touchegg
    emacs
    electrum
    monero-gui
    obsidian
    obs-studio
    tor
    tor-browser
    libreoffice
    thunar
    autorandr
    zathura
    pandoc
    xarchiver
    sxiv
    mpv
    libnotify

    # AI / Agents
    llama-cpp-vulkan
    inputs.claude-code-nix.packages.${system}.claude-code
    inputs.codex-cli-nix.packages.${system}.default
    inputs.antigravity-nix.packages.${system}.google-antigravity-cli
    cli-proxy-api
    mcp-nixos

    # Themes
    gnome-tweaks
    dracula-icon-theme
    bibata-cursors
    gnome-themes-extra
    adwaita-icon-theme
  ];

  # --- Session Environment ---
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "zen-beta";
    PDFVIEWER = "zathura";
    OPENER = "rifle";
    XDG_CURRENT_DESKTOP = "gtk"; # Use GTK file chooser portal in Electron/GTK apps
    GTK_USE_PORTAL = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "20";
    GTK_PATH = "${gtk-engine-murrine}/lib/gtk-2.0";
  };

  home.sessionPath = [
    "$HOME/scripts"
    "$HOME/ado"
    "/opt/stata18"
    "$HOME/.local/bin"
  ];

  # --- Zsh ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # System
      ll = "ls -l";
      reboot = "systemctl reboot";
      slp = "systemctl suspend";

      # Editors & Stata
      vim = "nvim";
      v = "nvim";
      vp = "nvim -p";
      sv = "sudo nvim";
      smp = "stata-mp";
      xmp = "xstata-mp";

      # NixOS
      update = "sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad";
      sysup = "nix flake update --flake ~/repos/nixos && sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad";

      # Workflow
      lad = "ls -d .*(/)";
      lsa = "ls -a .*(.)";
      pyenv = "source .venv/bin/activate";

      # Network
      won = "warp-cli connect";
      woff = "warp-cli disconnect";

      # Claude Code via local CLIProxyAPI (:8317); token lives in ~/.cli-proxy-api/token.
      claudex = "ANTHROPIC_BASE_URL=http://127.0.0.1:8317 "
        + "ANTHROPIC_AUTH_TOKEN=\"$(cat ~/.cli-proxy-api/token)\" "
        + "CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol "
        + "CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 "
        + "CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 "
        + "ENABLE_TOOL_SEARCH=false "
        + "claude --model gpt-5.6-sol";
    };

    initContent = ''
      PROMPT='%F{white}%n%f@%F{green}%m%f %F{blue}%B%~%b%f %# '
      RPROMPT='[%F{yellow}%?%f]'
      bindkey -v

      # Scoped local llama.cpp wrapper (keep OPENAI_* out of global env so Codex CLI isn't hijacked).
      local-ai() {
        OPENAI_BASE_URL="http://127.0.0.1:8080/v1" \
        OPENAI_API_KEY="sk-local" \
        "$@"
      }

      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"

      if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        exec startx
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "python" "sudo" ];
      theme = "";
    };
  };

  # --- Git ---
  programs.git = {
    enable = true;
    settings.user = {
      name = "Ved Shastry";
      email = "vedarshis@gmail.com";
    };
  };

  # --- XDG / MIME ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "text/x-lua" = "nvim.desktop";
      "application/x-lua" = "nvim.desktop";
      "application/octet-stream" = "nvim.desktop";
      "application/x-zerosize" = "nvim.desktop";

      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };

  # --- Theming ---
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
    gtk4.theme = config.gtk.theme;
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # --- User Services ---
  services.blueman-applet.enable = true;
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  systemd.user.services.llama-server = {
    Unit = {
      Description = "llama.cpp Router Mode Server";
      After = [ "network.target" ];
    };
    Service = {
      # CPU by default (add `-ngl 99` for GPU offload); persists Vulkan shader cache if used.
      ExecStart = "${llama-cpp-vulkan}/bin/llama-server --models-dir %h/ai --port 8080 -c 32768 --models-max 1 --flash-attn on";
      Restart = "always";
      RestartSec = "10";
      Environment = [
        "MESA_SHADER_CACHE_DIR=%h/.cache/mesa_shader_cache"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
      UnsetEnvironment = [ "OPENAI_API_KEY" "OPENAI_BASE_URL" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.stateVersion = "25.11";
}
