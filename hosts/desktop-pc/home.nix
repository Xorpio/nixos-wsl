{ pkgs, config, ... }:
{
  imports = [ ../common/home.nix ];

  home.username    = "xorpio";
  home.homeDirectory = "/home/xorpio";

  my.git = {
    userName = "Xorpio";
    userEmail = "3060868+Xorpio@users.noreply.github.com";
  };

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
    secrets."sync_server_encryption_secret" = {
      path = "${config.sops.defaultSymlinkPath}/sync_server_encryption_secret";
    };
  };

  # ── Shell aliases ─────────────────────────────────────────────────────────
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
    hm      = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
  };

  # ── Niri window manager ───────────────────────────────────────────────────
  xdg.configFile."niri/config.kdl".text = ''
    spawn-at-startup "noctalia-shell"
    spawn-at-startup "xwayland-satellite"

    input {
      keyboard {
        xkb {
          layout "us"
        }
      }

      touchpad {
        tap
        natural-scroll
      }
    }

    layout {
      gaps 8

      default-column-width { proportion 0.3333; }

      focus-ring {
        width 2
        active-color "#89b4fa"
        inactive-color "#45475a"
      }
    }

    binds {
      // Terminal and launcher
      Mod+Return { spawn "kitty"; }
      Mod+D { spawn "fuzzel"; }
      Mod+Shift+E { quit; }
      Mod+Q { close-window; }

      // Focus movement
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }
      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }

      // Move windows
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+L { move-column-right; }
      Mod+Shift+Left  { move-column-left; }
      Mod+Shift+Down  { move-window-down; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Right { move-column-right; }

      // Workspaces
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }

      Mod+Tab       { focus-workspace-down; }
      Mod+Shift+Tab { focus-workspace-up; }

      // Window sizing
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

      // Screenshots
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      // Monitor focus
      Mod+Shift+P { power-off-monitors; }
    }
  '';

  # ── Noctalia shell ────────────────────────────────────────────────────────
  programs.noctalia-shell = {
    enable = true;
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
