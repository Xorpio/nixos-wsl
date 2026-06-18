{
  description = "NixOS WSL — minimal bootstrap";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-wsl, home-manager, home-manager-unstable, sops-nix, nvf, noctalia }:
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

      # desktop-wsl: WSL setup without corporate cert
      nixosConfigurations.desktop-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./hosts/desktop-wsl
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              nvf.homeManagerModules.default
            ];
          }
        ];
      };

      homeConfigurations."xorpio@desktop-wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          sops-nix.homeManagerModules.sops
          nvf.homeManagerModules.default
          ./hosts/desktop-wsl/home.nix
        ];
      };

      # desktop-pc: Bare metal NixOS with Niri + Noctalia desktop
      nixosConfigurations.desktop-pc = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit noctalia; };
        modules = [
          home-manager-unstable.nixosModules.home-manager
          noctalia.nixosModules.default
          ./hosts/desktop-pc
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              nvf.homeManagerModules.default
              noctalia.homeModules.default
            ];
          }
        ];
      };

      homeConfigurations."xorpio@desktop-pc" = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
          sops-nix.homeManagerModules.sops
          nvf.homeManagerModules.default
          noctalia.homeModules.default
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
