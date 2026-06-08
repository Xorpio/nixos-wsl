{ pkgs, ... }:
{
  imports = [ ../common/nixos.nix ];

  wsl.defaultUser = "daf";
  users.users.daf.shell = pkgs.zsh;

  # PACCAR corporate CA — required before any network ops
  security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];

  home-manager.users.daf = import ./home.nix;
}
