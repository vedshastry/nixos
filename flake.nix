{
  description = "thinkpad-ved";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Rolling updates
    
    # Specific hardware tweaks for ThinkPad T14 Gen 5 (AMD)
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; 

    # Home Manager for user configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Zen Browser Flake
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Suckless tools
    my-dwm = {
    url = "github:vedshastry/dwm";
    flake = false; 		# these are standard C repos not flakes, so flake = false
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
        nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen4 # Gen 5 profile might not be explicit yet, Gen 4 is very close for HawkPoint
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # This passes 'inputs' to home.nix, fixing the "missing attribute" error
          home-manager.extraSpecialArgs = { inherit inputs; };

          home-manager.users.ved = import ./home.nix;
        }
      ];
    };
  };
}
