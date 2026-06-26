{ ... }:
{
  my.nixosModules.gaming = { pkgs, ... }: {
    programs.steam = {
      enable                        = true;
      remotePlay.openFirewall       = true;
      dedicatedServer.openFirewall  = false;
    };

    hardware.graphics.enable = true;
  };
}
