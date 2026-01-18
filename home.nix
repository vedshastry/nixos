{ config, pkgs, inputs, ... }:

{
  home.username = "ved";
  home.homeDirectory = "/home/ved";

  # Install User Packages
  home.packages = with pkgs; [
    # Core Tools
    ripgrep fd unzip jq tree
    ranger
    
    # Browsers
    inputs.zen-browser.packages."${pkgs.system}".specific
    
    # Research / Dev
    pulsar
    neovim
    python3
    R
    julia
    qgis
    
    # Cloud / Sync
    dropbox
    syncthing
    obsidian
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
    userName = "Ved Shastry";
    userEmail = "vedarshis@gmail.com";
  };

  home.stateVersion = "24.05";
}
