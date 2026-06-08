{ pkgs, ... }:
{
  imports = [ ../common/nixos.nix ];

  wsl.defaultUser = "xorpio";
  users.users.xorpio.shell = pkgs.zsh;

  home-manager.users.xorpio = import ./home.nix;
}
