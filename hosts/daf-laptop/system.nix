# System configuration for daf-laptop
{ config, pkgs, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # WSL configuration
  wsl.enable = true;
  wsl.defaultUser = "daf";

  # Network configuration
  networking.hostName = "daf-laptop";

  # Locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  # Enable nix flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
