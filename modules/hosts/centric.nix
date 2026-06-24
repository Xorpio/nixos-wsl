{ config, inputs, ... }:
let
  homeModules  = config.my.homeModules;
  nixosModules = config.my.nixosModules;

  hmModules = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.nvf.homeManagerModules.default
    homeModules.common
    homeModules.git
    homeModules.neovim
    homeModules.taskwarrior
    {
      home.username      = "niek";
      home.homeDirectory = "/home/niek";

      my.git = {
        userName  = "Niek";
        userEmail = "3060868+Xorpio@users.noreply.github.com";
      };

      sops = {
        age.keyFile              = "/home/niek/.config/sops/age/keys.txt";
        defaultSopsFile          = ../../secrets/machines/centric/taskwarrior.yaml;
        defaultSopsFormat        = "yaml";
        defaultSymlinkPath       = "/run/user/1000/secrets";
        defaultSecretsMountPoint = "/run/user/1000/secrets.d";
        secrets."sync_server_url".path               = "/run/user/1000/secrets/sync_server_url";
        secrets."sync_server_client_id".path         = "/run/user/1000/secrets/sync_server_client_id";
        secrets."sync_server_encryption_secret".path = "/run/user/1000/secrets/sync_server_encryption_secret";
      };

      home.shellAliases = {
        rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#centric";
        hm      = "home-manager switch --flake ~/nixos-wsl#niek@centric";
      };
    }
  ];
in
{
  flake.nixosConfigurations.centric = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.home-manager.nixosModules.home-manager
      nixosModules.common
      nixosModules.wsl
      nixosModules.vscode
      {
        wsl.defaultUser = "niek";
        users.users.niek.shell = inputs.nixpkgs.legacyPackages.x86_64-linux.zsh;
        home-manager.users.niek = { imports = hmModules; };
      }
    ];
  };

  flake.homeConfigurations."niek@centric" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs    = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = hmModules;
  };
}
