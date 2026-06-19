{ ... }:
{
  my.nixosModules.nvidia = { config, ... }: {
    nixpkgs.config.allowUnfree = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open               = false;
      nvidiaSettings     = true;
      package            = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.graphics.enable = true;
  };
}
