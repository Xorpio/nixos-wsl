{ pkgs, config, ... }:
{
  imports = [ ../common/home.nix ];

  home.username    = "xorpio";
  home.homeDirectory = "/home/xorpio";

  # ── SOPS secrets ──────────────────────────────────────────────────────────
  sops = {
    age.keyFile             = "/home/xorpio/.config/sops/age/keys.txt";
    defaultSopsFile         = ../../secrets/machines/desktop-pc/taskwarrior.yaml;
    defaultSopsFormat       = "yaml";
    defaultSymlinkPath      = "/run/user/1000/secrets";
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

  # ── Shell aliases ─────────────────────────────────────────────────────────
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc";
    hm      = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc";
  };

  # ── Starship prompt ───────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = ''
        [╭─](bold white)$os$username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration
        [╰─](bold white)$character'';

      os = {
        disabled = false;
        style    = "bg:#1c3a5e fg:#89b4fa bold";
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
        style              = "bg:#1e5f5f fg:#94e2d5 bold";
        format             = "[ $path ]($style)";
        truncation_length  = 3;
        truncate_to_repo   = true;
        substitutions."~"  = " ~";
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
}
