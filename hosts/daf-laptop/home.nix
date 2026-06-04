{ pkgs, ... }:
{
  home.username = "daf";
  home.homeDirectory = "/home/daf";
  home.stateVersion = "25.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # User packages — grow this list over time
  home.packages = with pkgs; [
    # add tools here
  ];
}
