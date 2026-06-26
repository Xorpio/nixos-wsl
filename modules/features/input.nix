{ ... }:
{
  my.nixosModules.input = { pkgs, ... }: {
    # Enable joystick/gamepad support
    hardware.uinput.enable = true;

    # Add xboxdrv and related packages
    services.xboxdrv.enable = true;

    # Add input-related packages
    environment.systemPackages = with pkgs; [
      xpadneo
      xboxdrv
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
