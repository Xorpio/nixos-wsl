{ pkgs, config, lib, ... }:
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
  echo " uda.reviewed.type=date"
  echo " uda.reviewed.label=Reviewed"
  echo " report._reviewed.description=Tasksh review report.  Adjust the filter to your needs."
  echo " report._reviewed.columns=uuid"
  echo " report._reviewed.sort=reviewed+,modified+"
  echo " report._reviewed.filter=( reviewed.none: or reviewed.before:now-6days ) and ( +PENDING or +WAITING )"
  echo "news.version=3.4.1"
  echo "context.work.read=+daf or +centric"
  echo "context.daf.read=+daf"
  echo "context.daf.write=+daf"
  echo "context.centric.read=+centric"
  echo "context.centric.write=+centric"
  echo "context.home.read=-daf and -centric"
  echo ""
  echo " # New"
} > "$HOME/.taskrc"

chmod 600 "$HOME/.taskrc"
  '';

  # setup recurring sync timer
  systemd.user.services.task-sync = {
     Unit = {
       Description = "Taskwarrior sync";
     };

     Service = {
       Type = "oneshot";
       ExecStart = "${pkgs.taskwarrior3}/bin/task sync";
     };
   };

   systemd.user.timers.task-sync = {
     Unit = {
       Description = "Periodic Taskwarrior sync";
     };

     Timer = {
       OnBootSec = "2m";
       OnUnitActiveSec = "5m";
       Persistent = true;
     };

     Install = {
       WantedBy = [ "timers.target" ];
     };
   };
}
