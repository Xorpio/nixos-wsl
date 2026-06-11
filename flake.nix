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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, sops-nix, nvf }:
    {
      # daf-laptop: Corporate setup with PACCAR cert
      nixosConfigurations.daf-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./hosts/daf-laptop
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              nvf.homeManagerModules.default
            ];
          }
        ];
      };

      nix.settings.experimental-features = ["nix-command" "flakes" ];

      homeConfigurations."daf@daf-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          sops-nix.homeManagerModules.sops
          nvf.homeManagerModules.default
          ./hosts/daf-laptop/home.nix
        ];
      };

      # desktop-pc: Clean setup without corporate cert
      nixosConfigurations.desktop-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./hosts/desktop-pc
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              nvf.homeManagerModules.default
            ];
          }
        ];
      };

      homeConfigurations."xorpio@desktop-pc" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          sops-nix.homeManagerModules.sops
          nvf.homeManagerModules.default
          ./hosts/desktop-pc/home.nix
        ];
      };

      # centric: Clean setup without corporate cert
      nixosConfigurations.centric = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./hosts/centric
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              nvf.homeManagerModules.default
            ];
          }
        ];
      };

      homeConfigurations."niek@centric" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          sops-nix.homeManagerModules.sops
          nvf.homeManagerModules.default
          ./hosts/centric/home.nix
        ];
      };
    };
}
