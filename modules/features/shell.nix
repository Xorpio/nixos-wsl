{ ... }:
{
  my.nixosModules.common = { pkgs, ... }: {
    time.timeZone = "Europe/Amsterdam";

    programs.zsh.enable = true;
    services.openssh.enable = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "25.05";

    environment.systemPackages = with pkgs; [
      git curl wget home-manager sops tmux
    ];

    home-manager = {
      useGlobalPkgs   = true;
      useUserPackages = true;
    };
  };

  my.homeModules.common = { pkgs, config, lib, ... }: {
    home.stateVersion = "25.05";
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      yazi pre-commit ripgrep fzf zoxide
    ];

    # Restart sops-nix only after home-manager has reloaded user systemd units,
    # avoiding a race between secret materialisation and unit activation order.
    home.activation.sops-nix = lib.mkForce (config.lib.dag.entryAfter [ "reloadSystemd" ] ''
      if env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" PATH="${pkgs.systemd}/bin:$PATH" ${pkgs.systemd}/bin/systemctl --user list-unit-files | ${pkgs.gnugrep}/bin/grep -q '^sops-nix\.service'; then
        env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" PATH="${pkgs.systemd}/bin:$PATH" ${pkgs.systemd}/bin/systemctl restart --user sops-nix.service
      fi
    '');

    programs.zsh = {
      enable                    = true;
      autocd                    = true;
      autosuggestion.enable     = true;
      syntaxHighlighting.enable = true;
      history = {
        size       = 10000;
        save       = 10000;
        ignoreDups = true;
        share      = true;
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
          disabled      = false;
          style         = "bg:#1c3a5e fg:#89b4fa bold";
          symbols.NixOS = "❄ ";
        };

        username = {
          show_always = true;
          style_user  = "bg:#1c3a5e fg:#cdd6f4 bold";
          style_root  = "bg:#6e0000 fg:#f38ba8 bold";
          format      = "[ $user ]($style)";
        };

        hostname = {
          ssh_only = false;
          style    = "bg:#1c3a5e fg:#a6adc8";
          format   = "[@$hostname ]($style)";
        };

        directory = {
          style             = "bg:#1e5f5f fg:#94e2d5 bold";
          format            = "[ $path ]($style)";
          truncation_length = 3;
          truncate_to_repo  = true;
          substitutions."~" = " ~";
        };

        git_branch = {
          style  = "bg:#3b1f6e fg:#cba6f7 bold";
          format = "[ $symbol$branch ]($style)";
          symbol = " ";
        };

        git_status = {
          style  = "bg:#3b1f6e fg:#f5c2e7";
          format = "[$all_status$ahead_behind]($style) ";
        };

        nix_shell = {
          disabled = false;
          style    = "bg:#1c3a5e fg:#89dceb";
          format   = "[ ❄ $name ]($style)";
        };

        cmd_duration = {
          min_time = 2000;
          style    = "fg:yellow";
          format   = " [$duration]($style)";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol   = "[❯](bold red)";
        };
      };
    };
  };
}
