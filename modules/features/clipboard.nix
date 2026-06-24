{ ... }:
{
  my.homeModules.clipboard = { pkgs, ... }: {
    home.packages = [ pkgs.ringboard ];

    systemd.user.services.ringboard-server = {
      Unit = {
        Description = "Ringboard clipboard server";
        Documentation = "https://github.com/SUPERCILEX/clipboard-history";
      };
      Service = {
        Type = "notify";
        ExecStart = "${pkgs.ringboard}/bin/ringboard-server";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.ringboard-wayland = {
      Unit = {
        Description = "Ringboard Wayland clipboard watcher";
        Documentation = "https://github.com/SUPERCILEX/clipboard-history";
        Requires = [ "ringboard-server.service" ];
        After = [ "ringboard-server.service" "graphical-session.target" ];
        BindsTo = [ "graphical-session.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.ringboard-wayland}/bin/ringboard-wayland";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
