{ pkgs, ... }:
{
  wsl.enable = true;

  time.timeZone = "Europe/Amsterdam";

  # zsh must be in /etc/shells for it to be usable as a login shell
  programs.zsh.enable = true;

  # SSH needed for SOPS Age key derivation from SSH keys
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    home-manager
    sops
  ];

  home-manager.useGlobalPkgs    = true;
  home-manager.useUserPackages  = true;

  nix.settings.experimental-features = ["nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
