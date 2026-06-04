{ pkgs, ... }:
{
  # WSL basics
  wsl.enable = true;
  wsl.defaultUser = "daf";

  # PACCAR corporate CA — required before any network ops
  # Place the cert at /etc/nixos/paccar-root.crt before rebuilding
  security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];

  # Minimal useful packages — add more as needed
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  system.stateVersion = "24.11";
}
