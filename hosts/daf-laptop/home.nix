{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shell
    ../../modules/neovim
    ../../modules/git
    ../../modules/dev-tools
    ../../modules/sops
  ];

  home.stateVersion = "24.05";

  # Enable all modules
  modules = {
    shell = {
      enable = true;
      defaultShell = "zsh";
      additionalAliases = {
        nix-rebuild = "sudo nixos-rebuild switch --flake /root/.config/nixos";
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimdiffAlias = true;
      colorscheme = "gruvbox";
    };

    git = {
      enable = true;
      userName = "Daf";
      userEmail = "daf@example.com";
    };

    dev-tools = {
      enable = true;
      includeCore = true;
      includeSearch = true;
      includeLs = true;
      includeViewers = true;
    };

    sops = {
      enable = true;
      enableManagement = true;
    };
  };

  # Symlink nvim-config directory to ~/.config/nvim for live editing
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/root/nvim-config";
  };
}
