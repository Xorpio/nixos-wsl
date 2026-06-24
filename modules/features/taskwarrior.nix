{ ... }:
{
  my.homeModules.taskwarrior = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      tasksh
      taskwarrior-tui
      taskwarrior3
    ];

    home.activation.generateTaskrc = config.lib.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
      export SYNC_SERVER_URL=$(cat "${config.sops.secrets.sync_server_url.path}")
      export SYNC_SERVER_CLIENT_ID=$(cat "${config.sops.secrets.sync_server_client_id.path}")
      export SYNC_SERVER_ENCRYPTION_SECRET=$(cat "${config.sops.secrets.sync_server_encryption_secret.path}")

      ${pkgs.envsubst}/bin/envsubst < "${./taskwarrior/taskrc.tpl}" > "$HOME/.taskrc"

      chmod 600 "$HOME/.taskrc"
    '';

    systemd.user.services.generate-taskrc = {
      Unit = {
        Description = "Generate .taskrc from sops secrets";
        After       = [ "sops-nix.service" ];
        Wants       = [ "sops-nix.service" ];
      };
      Service = {
        Type      = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScript "generate-taskrc" ''
            SYNC_SERVER_URL=$(cat ${config.sops.secrets.sync_server_url.path})
            SYNC_SERVER_CLIENT_ID=$(cat ${config.sops.secrets.sync_server_client_id.path})
            SYNC_SERVER_ENCRYPTION_SECRET=$(cat ${config.sops.secrets.sync_server_encryption_secret.path})
            export SYNC_SERVER_URL SYNC_SERVER_CLIENT_ID SYNC_SERVER_ENCRYPTION_SECRET
            ${pkgs.envsubst}/bin/envsubst < ${./taskwarrior/taskrc.tpl} > ${config.home.homeDirectory}/.taskrc
            chmod 600 ${config.home.homeDirectory}/.taskrc
          '';
        in "${script}";
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.task-sync = {
      Unit = {
        Description = "Taskwarrior sync";
        After       = [ "generate-taskrc.service" ];
        Wants       = [ "generate-taskrc.service" ];
      };
      Service = {
        Type      = "oneshot";
        ExecStart = "${pkgs.taskwarrior3}/bin/task sync";
      };
    };

    systemd.user.timers.task-sync = {
      Unit.Description = "Periodic Taskwarrior sync";
      Timer = {
        OnBootSec       = "2m";
        OnUnitActiveSec = "5m";
        Persistent      = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
