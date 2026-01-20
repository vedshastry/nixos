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
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen4 # Gen 5 profile might not be explicit yet, Gen 4 is very close for HawkPoint
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ved = import ./home.nix;
        }
      ];
    };
  };
}
