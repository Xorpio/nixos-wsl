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
cat > "$HOME/.taskrc" <<'TASKRC'
# Taskwarrior configuration with synced settings
dateformat=Y-M-D H:N
dateformat.info=Y-M-D H:N:S
dateformat.annotation=Y-M-D H:N

# Sync configuration (populated from secrets)
sync.server.url=$(cat "${config.sops.secrets."sync_server_url".path}")
sync.server.client_id=$(cat "${config.sops.secrets."sync_server_client_id".path}")
sync.encryption_secret=$(cat "${config.sops.secrets."sync_server_encryption_secret".path}")
TASKRC
chmod 600 "$HOME/.taskrc"
  '';
}
