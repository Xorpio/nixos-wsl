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

  home.activation.generateTaskrc = config.lib.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
export SYNC_SERVER_URL=$(cat "${config.sops.secrets.sync_server_url.path}")
export SYNC_SERVER_CLIENT_ID=$(cat "${config.sops.secrets.sync_server_client_id.path}")
export SYNC_SERVER_ENCRYPTION_SECRET=$(cat "${config.sops.secrets.sync_server_encryption_secret.path}")

${pkgs.envsubst}/bin/envsubst < "${./taskwarrior/taskrc.tpl}" > "$HOME/.taskrc"

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
