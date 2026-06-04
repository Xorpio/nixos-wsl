{
  description = "Multi-machine NixOS configuration for WSL and home-desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      # Define the systems and their usernames
      hosts = {
        daf-laptop = { system = "x86_64-linux"; user = "daf"; };
        centric-laptop = { system = "x86_64-linux"; user = "centric"; };
        home-desktop = { system = "x86_64-linux"; user = "nixos"; };
      };

      # Create inputs set for passing to modules
      inputs = { inherit nixpkgs home-manager sops-nix; };

      # Helper function to create a host configuration
      mkHostConfig = hostname: hostConfig:
        let
          pkgs = nixpkgs.legacyPackages.${hostConfig.system};
          user = hostConfig.user;
        in
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = { inherit inputs self; };
          modules = [
            # Import per-machine system configuration
            (./. + "/hosts/${hostname}/system.nix")

            # Home manager integration at system level
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = {
                # Import host-specific home configuration
                imports = [
                  (./. + "/hosts/${hostname}/home.nix")
                  sops-nix.homeManagerModules.sops
                ];
              };
            }
          ];
        };
    in
    {
      # Define nixosConfigurations for all three machines
      nixosConfigurations = {
        daf-laptop = mkHostConfig "daf-laptop" hosts.daf-laptop;
        centric-laptop = mkHostConfig "centric-laptop" hosts.centric-laptop;
        home-desktop = mkHostConfig "home-desktop" hosts.home-desktop;
      };

      # Define homeConfigurations for standalone home-manager usage
      homeConfigurations = {
        "daf@daf-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs self; };
          modules = [
            ./hosts/daf-laptop/home.nix
            sops-nix.homeManagerModules.sops
          ];
        };
        "centric@centric-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs self; };
          modules = [
            ./hosts/centric-laptop/home.nix
            sops-nix.homeManagerModules.sops
          ];
        };
        "nixos@home-desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs self; };
          modules = [
            ./hosts/home-desktop/home.nix
            sops-nix.homeManagerModules.sops
          ];
        };
      };

      # Development environment for working on the flake itself
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nix
          git
          pre-commit
        ];
      };
    };
}
