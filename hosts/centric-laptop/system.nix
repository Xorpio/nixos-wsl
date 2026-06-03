# System configuration for centric-laptop
{ config, pkgs, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # WSL configuration
  wsl.enable = true;
  wsl.defaultUser = "centric";

  # Network configuration
  networking.hostName = "centric-laptop";

  # Locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  # Enable nix flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
