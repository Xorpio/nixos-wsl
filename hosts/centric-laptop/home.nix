{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shell
    ../../modules/git
    ../../modules/dev-tools
    ../../modules/sops
  ];

  home.username = "centric";
  home.homeDirectory = "/home/centric";
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
      userName = "Centric";
      userEmail = "centric@example.com";
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
