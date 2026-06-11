{ pkgs, ... }:
{
  imports = [ ../common/nixos.nix ];

  wsl.defaultUser = "niek";
  users.users.niek.shell = pkgs.zsh;

  home-manager.users.niek = import ./home.nix;
}
