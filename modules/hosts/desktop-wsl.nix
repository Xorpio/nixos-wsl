{ config, inputs, ... }:
let
  homeModules  = config.my.homeModules;
  nixosModules = config.my.nixosModules;
in
{
  flake.nixosConfigurations.desktop-wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.home-manager.nixosModules.home-manager
      nixosModules.common
      nixosModules.wsl
      {
        wsl.defaultUser = "xorpio";
        users.users.xorpio.shell = inputs.nixpkgs.legacyPackages.x86_64-linux.zsh;

        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nvf.homeManagerModules.default
        ];

        home-manager.users.xorpio = {
          imports = [
            homeModules.common
            homeModules.git
            homeModules.neovim
            homeModules.taskwarrior
          ];

          home.username      = "xorpio";
          home.homeDirectory = "/home/xorpio";

          my.git = {
            userName  = "Xorpio";
            userEmail = "3060868+Xorpio@users.noreply.github.com";
          };

          sops = {
            age.keyFile              = "/home/xorpio/.config/sops/age/keys.txt";
            defaultSopsFile          = ../../secrets/machines/desktop-wsl/taskwarrior.yaml;
            defaultSopsFormat        = "yaml";
            defaultSymlinkPath       = "/run/user/1000/secrets";
            defaultSecretsMountPoint = "/run/user/1000/secrets.d";
            secrets."sync_server_url".path               = "/run/user/1000/secrets/sync_server_url";
            secrets."sync_server_client_id".path         = "/run/user/1000/secrets/sync_server_client_id";
            secrets."sync_server_encryption_secret".path = "/run/user/1000/secrets/sync_server_encryption_secret";
          };

          home.shellAliases = {
            rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-wsl";
            hm      = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-wsl";
          };
        };
      }
    ];
  };
}
