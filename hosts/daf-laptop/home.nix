{ pkgs, ... }:
{
  home.username = "daf";
  home.homeDirectory = "/home/daf";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # add tools here
  ];

  # rebuild     → full NixOS system + home rebuild (slow, use when changing system.nix)
  # hm          → home-manager only (fast, use when changing home.nix)
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
    hm      = "home-manager switch --flake ~/nixos-wsl#daf@daf-laptop";
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

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = ''
        [╭─](bold white)$os$username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration
        [╰─](bold white)$character'';

      os = {
        disabled = false;
        style = "bg:blue fg:white bold";
        symbols.NixOS = "❄ ";
      };

      username = {
        show_always = true;
        style_user = "bg:blue fg:white bold";
        style_root = "bg:red fg:white bold";
        format = "[ $user ]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "bg:blue fg:white";
        format = "[@$hostname ]($style)";
      };

      directory = {
        style = "bg:cyan fg:black bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
        substitutions = {
          "~" = " ~";
        };
      };

      git_branch = {
        style = "bg:purple fg:white bold";
        format = "[ $symbol$branch ]($style)";
        symbol = " ";
      };

      git_status = {
        style = "bg:purple fg:white";
        format = "[$all_status$ahead_behind]($style) ";
      };

      nix_shell = {
        disabled = false;
        style = "bg:blue fg:white";
        format = "[ ❄ $name ]($style)";
      };

      cmd_duration = {
        min_time = 2000;
        style = "fg:yellow";
        format = " [$duration]($style)";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
