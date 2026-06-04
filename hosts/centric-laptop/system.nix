# System configuration for centric-laptop
{ config, pkgs, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # Network configuration
  networking.hostName = "centric-laptop";

  # Locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  # Enable nix flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Filesystem configuration - minimal for WSL
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  # Boot loader - dummy for WSL
  boot.loader.grub.enable = false;
  boot.isContainer = true;
  
  # Basic user setup for WSL
  users.users.centric = {
    isNormalUser = true;
    home = "/home/centric";
    group = "users";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
  };
}
