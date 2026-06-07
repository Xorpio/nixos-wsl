{ pkgs, ... }:
{
  # WSL basics
  wsl.enable = true;
  wsl.defaultUser = "daf";

  time.timeZone = "Europe/Amsterdam";

  # PACCAR corporate CA — required before any network ops
  security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];

  # zsh must be enabled at system level so it lands in /etc/shells
  programs.zsh.enable = true;

  # Set zsh as default shell for daf
  users.users.daf.shell = pkgs.zsh;

  # SSH needed for SOPS Age key derivation from SSH keys
  services.openssh.enable = true;

  # System-level packages (available to all users)
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    home-manager
    sops
  ];

  # Home-manager wired in at system level
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.daf = import ./home.nix;

  system.stateVersion = "25.05";
}
