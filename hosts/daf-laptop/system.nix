# System configuration for daf-laptop
{ config, pkgs, ... }:

{
  # State version
  system.stateVersion = "24.05";

  # Network configuration
  networking.hostName = "daf-laptop";

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
  users.users.daf = {
    isNormalUser = true;
    home = "/home/daf";
    group = "users";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
  };

  # PACCAR corporate TLS trust — daf-laptop only
  # The cert lives at /etc/nixos/paccar-root.crt inside the NixOS instance.
  # It is NOT in git. Copy it manually before running nixos-rebuild switch.
  # See openspec/changes/configure-paccar-tls-trust/ for full instructions.
  security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];
}
