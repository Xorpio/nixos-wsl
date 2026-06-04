{ pkgs, ... }:
{
  home.username = "daf";
  home.homeDirectory = "/home/daf";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # User packages — grow this list over time
  home.packages = with pkgs; [
    # add tools here
  ];

  # Convenience aliases
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
  };
}
