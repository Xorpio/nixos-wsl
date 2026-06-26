{ ... }:
{
  my.nixosModules.gamepad = { pkgs, ... }: {
    hardware.uinput.enable = true;

    services.udev.packages = with pkgs; [ xpadneo ];

    users.users.xorpio.extraGroups = [ "input" "uinput" ];
  };

  my.homeModules.gamepad = { pkgs, ... }: {
    home.packages = with pkgs; [
      xpadneo
      antimicrox
      joystick
    ];
  };
}
