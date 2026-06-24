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
      home.username      = "daf";
      home.homeDirectory = "/home/daf";

      my.git = {
        userName  = "Niek";
        userEmail = "3060868+Xorpio@users.noreply.github.com";
      };

      sops = {
        age.keyFile              = "/home/daf/.config/sops/age/keys.txt";
        defaultSopsFile          = ../../secrets/machines/daf-laptop/taskwarrior.yaml;
        defaultSopsFormat        = "yaml";
        defaultSymlinkPath       = "/run/user/1000/secrets";
        defaultSecretsMountPoint = "/run/user/1000/secrets.d";
        secrets."sync_server_url".path               = "/run/user/1000/secrets/sync_server_url";
        secrets."sync_server_client_id".path         = "/run/user/1000/secrets/sync_server_client_id";
        secrets."sync_server_encryption_secret".path = "/run/user/1000/secrets/sync_server_encryption_secret";
      };

      home.shellAliases = {
        rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
        hm      = "home-manager switch --flake ~/nixos-wsl#daf@daf-laptop";
      };
    }
  ];
in
{
  flake.nixosConfigurations.daf-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.home-manager.nixosModules.home-manager
      nixosModules.common
      nixosModules.wsl
      nixosModules.vscode
      {
        wsl.defaultUser = "daf";
        users.users.daf.shell = inputs.nixpkgs.legacyPackages.x86_64-linux.zsh;

        # PACCAR corporate CA is managed out-of-repo on the machine.
        security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];
        nix.settings.ssl-cert-file = "/etc/nixos/paccar-root.crt";

        home-manager.users.daf = { imports = hmModules; };
      }
    ];
  };

  flake.homeConfigurations."daf@daf-laptop" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs    = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = hmModules;
  };
}
