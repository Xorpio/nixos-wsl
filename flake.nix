{
  description = "NixOS WSL — minimal bootstrap";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager }:
    {
      # Full system rebuild: `rebuild`
      nixosConfigurations.daf-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./hosts/daf-laptop
        ];
      };

      # Home-only rebuild: `hm`
      homeConfigurations."daf@daf-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./hosts/daf-laptop/home.nix ];
      };
    };
}
