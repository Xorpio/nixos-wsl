{ ... }:
{
  my.nixosModules.input = { pkgs, config, ... }: {
    # Enable joystick/gamepad support
    hardware.uinput.enable = true;

    # Add input-related packages
    boot.extraModulePackages = with config.boot.kernelPackages; [
      xpadneo
    ];

    environment.systemPackages = with pkgs; [
      jstest-gtk
    ];

    # Add user to input group for accessing joystick devices
    users.groups.input = { };
  };

  my.homeModules.input = { pkgs, ... }: {
    home.packages = with pkgs; [
      antimicrox
      gamepad-tool
    ];
  };
}
