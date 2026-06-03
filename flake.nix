{
  description = "Multi-machine NixOS configuration for WSL and home-desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }:
    let
      # Define the systems and their usernames
      hosts = {
        daf-laptop = { system = "x86_64-linux"; user = "daf"; };
        centric-laptop = { system = "x86_64-linux"; user = "centric"; };
        home-desktop = { system = "x86_64-linux"; user = "nixos"; };
      };

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
            # Minimal system configuration for WSL
            {
              # Basic system settings
              system.stateVersion = "24.05";
              
              # Required for WSL
              wsl.enable = true;
              wsl.defaultUser = user;

              # Network configuration
              networking.hostName = hostname;
            }

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
