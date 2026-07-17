{
  description = "thinkpad-ved";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Rolling updates

    # Shared stable (nixos-25.05) pin for a couple of packages that misbehave
    # on unstable; consumed in home.nix.
    #  - flameshot: unstable's 14 (Qt6) forces every capture through the
    #    xdg-desktop-portal Screenshot API, which hangs 30s on bare dwm (no
    #    portal backend). 25.05 ships the Qt5 12.1.0 build that grabs X11.
    #  - qgis: unstable's pdal fails to build against the newer GDAL and needed
    #    a -fpermissive override -> constant from-source rebuilds. 25.05 builds
    #    both cleanly from cache.
    nixpkgs-flameshot.url = "github:nixos/nixpkgs/nixos-25.05";

    # Specific hardware tweaks for ThinkPad T14 Gen 5 (AMD)
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home Manager for user configuration
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Zen Browser Flake
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Opencode
    opencode-flake.url = "github:aodhanhayter/opencode-flake";

    # Ollama
    ollama-flake.url = "github:abysssol/ollama-flake";

    # Claude Code
    claude-code-nix.url = "github:sadjow/claude-code-nix";

    # Codex CLI
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";

    # Antigravity 
    antigravity-nix.url = "github:jacopone/antigravity-nix";

    # Suckless tools
    my-dwm = {
      url = "github:vedshastry/dwm";
      flake = false;
    };
    my-st = {
      url = "github:vedshastry/st";
      flake = false;
    };
    my-dmenu = {
      url = "github:vedshastry/dmenu";
      flake = false;
    };
    my-slstatus = {
      url = "github:vedshastry/slstatus";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5 
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";

          # Pass 'inputs' to home.nix so it can access claude-code-nix
          home-manager.extraSpecialArgs = { inherit inputs; };

          home-manager.users.ved = import ./home.nix;
        }
      ];
    };
  };
}
