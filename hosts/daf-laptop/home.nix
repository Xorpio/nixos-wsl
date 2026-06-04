{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shell
    ../../modules/git
    ../../modules/dev-tools
    ../../modules/sops
  ];

  home.username = "daf";
  home.homeDirectory = "/home/daf";
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;

  # Task management and editor tools
  home.packages = with pkgs; [
    taskwarrior3
    tasksh
    taskwarrior-tui
    neovim
  ];

  # Vim configuration
  programs.vim.enable = true;
  programs.vim.settings.number = true;

  # Enable all modules
  modules = {
    shell = {
      enable = true;
      defaultShell = "zsh";
      additionalAliases = {
        nix-rebuild = "sudo nixos-rebuild switch --flake /root/.config/nixos";
      };
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
    };
  };
}
