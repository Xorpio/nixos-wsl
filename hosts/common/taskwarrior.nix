{ pkgs, config, ... }:
{
  # ── Taskwarrior ───────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    tasksh
    taskwarrior-tui
  ];

  programs.taskwarrior = {
    enable  = true;
    package = pkgs.taskwarrior3;
    config = {
      dateformat              = "Y-M-D H:N";
      "dateformat.info"       = "Y-M-D H:N:S";
      "dateformat.annotation" = "Y-M-D H:N";
    };
  };

  home.activation.generateTaskrc = config.lib.dag.entryAfter ["writeBoundary" "sops-nix"] ''
mkdir -p "$HOME/.config/task" 2>/dev/null || true

sync_server_url=$(cat "${config.sops.secrets."sync_server_url".path}")
sync_server_client_id=$(cat "${config.sops.secrets."sync_server_client_id".path}")
sync_server_encryption_secret=$(cat "${config.sops.secrets."sync_server_encryption_secret".path}")

{
  echo '# Taskwarrior configuration with synced settings'
  echo 'dateformat=Y-M-D H:N'
  echo 'dateformat.info=Y-M-D H:N:S'
  echo 'dateformat.annotation=Y-M-D H:N'
  echo
  echo '# Sync configuration (populated from secrets)'
  echo "sync.server.url=$sync_server_url"
  echo "sync.server.client_id=$sync_server_client_id"
  echo "sync.encryption_secret=$sync_server_encryption_secret"
} > "$HOME/.taskrc"

chmod 600 "$HOME/.taskrc"
  '';
}
