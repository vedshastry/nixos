{ config, pkgs, inputs, ... }:

{
  home.username = "ved";
  home.homeDirectory = "/home/ved";

  # Install User Packages
  home.packages = with pkgs; [
    # Core Tools
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
    xfce.xfce4-power-manager
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
    slack
    dropbox
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

  # ZSH Config (Migrating from Antibody)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Oh-My-Zsh is easiest, but you can list manual plugins too
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "python" "docker" ];
      theme = "robbyrussell"; # Or whatever you prefer
    };

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config#thinkpad"; # One command update!
    };
  };

  # Git Config
  programs.git = {
    enable = true;
    settings.user.name = "Ved Shastry";
    settings.user.email = "vedarshis@gmail.com";
  };

  home.stateVersion = "25.11";
}
