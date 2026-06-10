{ pkgs, config, ... }:
{
  imports = [ ../common/home.nix ];

  home.username      = "daf";
  home.homeDirectory = "/home/daf";

  my.git = {
    userName = "Niek";
    userEmail = "3060868+Xorpio@users.noreply.github.com";
  };

  # ── SOPS secrets ──────────────────────────────────────────────────────────
  sops = {
    age.keyFile              = "/home/daf/.config/sops/age/keys.txt";
    defaultSopsFile          = ../../secrets/machines/daf-laptop/taskwarrior.yaml;
    defaultSopsFormat        = "yaml";
    defaultSymlinkPath       = "/run/user/1000/secrets";
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
    rebuild = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
    hm      = "sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop";
  };

  # ── Starship prompt ───────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = ''
$username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration
$character'';
    };
  };
}
