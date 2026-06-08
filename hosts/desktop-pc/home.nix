{ pkgs, config, ... }:
{
  home.username = "xorpio";
  home.homeDirectory = "/home/xorpio";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  sops = {
    age.keyFile = "/home/xorpio/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/machines/desktop-pc/taskwarrior.yaml;
    defaultSopsFormat = "yaml";
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

    secrets."sync_server_url" = {
      path = "${config.sops.defaultSymlinkPath}/sync_server_url";
    };
    secrets."sync_server_client_id" = {
      path = "${config.sops.defaultSymlinkPath}/sync_server_client_id";
    };
    secrets."sync_encryption_secret" = {
      path = "${config.sops.defaultSymlinkPath}/sync_encryption_secret";
    };
  };

  home.packages = with pkgs; [
    tasksh
    taskwarrior-tui
  ];

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      dateformat         = "Y-M-D H:N";
      "dateformat.info"  = "Y-M-D H:N:S";
      "dateformat.annotation" = "Y-M-D H:N";
    };
  };

  home.activation.generateTaskrc = config.lib.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.bash}/bin/bash << 'EOF'
      mkdir -p ~/.config/taskwarrior 2>/dev/null || true
      cat > ~/.taskrc << TASKRC
# Taskwarrior configuration with synced settings
dateformat=Y-M-D H:N
dateformat.info=Y-M-D H:N:S
dateformat.annotation=Y-M-D H:N

# Sync configuration (populated from secrets)
sync.server.url=$(cat "${config.sops.secrets."sync_server_url".path}")
sync.server.client_id=$(cat "${config.sops.secrets."sync_server_client_id".path}")
sync.encryption_secret=$(cat "${config.sops.secrets."sync_encryption_secret".path}")
TASKRC
      chmod 600 ~/.taskrc
    EOF
  '';

  # rebuild / hm → both trigger nixos-rebuild (HM is managed at system level;
  #                Nix caches mean a home-only change is still fast)
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc";
    hm      = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc";
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

      # Colour palette: deep steel blue → teal → indigo → magenta
      # All segments use bright fg on dark bg for easy reading
      os = {
        disabled = false;
        style = "bg:#1c3a5e fg:#89b4fa bold";
        symbols.NixOS = "❄ ";
      };

      username = {
        show_always = true;
        style_user = "bg:#1c3a5e fg:#cdd6f4 bold";
        style_root  = "bg:#6e0000 fg:#f38ba8 bold";
        format = "[ $user ]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "bg:#1c3a5e fg:#a6adc8";
        format = "[@$hostname ]($style)";
      };

      directory = {
        style = "bg:#1e5f5f fg:#94e2d5 bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
        substitutions = {
          "~" = " ~";
        };
      };

      git_branch = {
        style = "bg:#3b1f6e fg:#cba6f7 bold";
        format = "[ $symbol$branch ]($style)";
        symbol = " ";
      };

      git_status = {
        style = "bg:#3b1f6e fg:#f5c2e7";
        format = "[$all_status$ahead_behind]($style) ";
      };

      nix_shell = {
        disabled = false;
        style = "bg:#1c3a5e fg:#89dceb";
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
