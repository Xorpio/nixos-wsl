{ pkgs, ... }:
{
  # WSL basics
  wsl.enable = true;
  wsl.defaultUser = "daf";

  # PACCAR corporate CA — required before any network ops
  security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];

  # System-level packages (available to all users)
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # Home-manager wired in at system level
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.daf = import ./home.nix;

  system.stateVersion = "25.05";
}
