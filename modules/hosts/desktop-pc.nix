{ config, inputs, ... }:
let
  homeModules  = config.my.homeModules;
  nixosModules = config.my.nixosModules;
in
{
  flake.nixosConfigurations.desktop-pc = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./hardware/desktop-pc.nix
      inputs.home-manager-unstable.nixosModules.home-manager
      inputs.noctalia.nixosModules.default
      nixosModules.common
      nixosModules.niri
      nixosModules.audio
      nixosModules.nvidia
      nixosModules.desktop
      {
        boot.loader.systemd-boot.enable      = true;
        boot.loader.efi.canTouchEfiVariables = true;

        users.users.xorpio = {
          isNormalUser = true;
          shell        = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.zsh;
          extraGroups  = [ "wheel" "networkmanager" "video" "audio" ];
        };

        networking.hostName              = "desktop-pc";
        networking.networkmanager.enable = true;

        services.xserver.xkb = {
          layout  = "us";
          variant = "";
        };

        environment.systemPackages = with inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; [
          claude-code
          kitty
          fuzzel
          xwayland-satellite
        ];

        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nvf.homeManagerModules.default
          inputs.noctalia.homeModules.default
        ];

        home-manager.users.xorpio = {
          imports = [
            homeModules.common
            homeModules.git
            homeModules.neovim
            homeModules.taskwarrior
            homeModules.niri
            homeModules.desktop
          ];

          home.username      = "xorpio";
          home.homeDirectory = "/home/xorpio";

          my.git = {
            userName  = "Xorpio";
            userEmail = "3060868+Xorpio@users.noreply.github.com";
          };

          sops = {
            age.keyFile              = "/home/xorpio/.config/sops/age/keys.txt";
            defaultSopsFile          = ../../secrets/machines/desktop-pc/taskwarrior.yaml;
            defaultSopsFormat        = "yaml";
            defaultSymlinkPath       = "/run/user/1000/secrets";
            defaultSecretsMountPoint = "/run/user/1000/secrets.d";
            secrets."sync_server_url".path               = "/run/user/1000/secrets/sync_server_url";
            secrets."sync_server_client_id".path         = "/run/user/1000/secrets/sync_server_client_id";
            secrets."sync_server_encryption_secret".path = "/run/user/1000/secrets/sync_server_encryption_secret";
          };

          home.shellAliases = {
            rebuild = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
            hm      = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
          };
        };
      }
    ];
  };
}
