{ pkgs, config, lib, ... }:
{
  imports = [
    ./git.nix
    ./neovim.nix
    ./taskwarrior.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    yazi
    pre-commit
  ];

  # Write ~/.taskrc from sops secrets (secrets are defined per-host)
  # Override sops activation ordering: restart the user unit only after
  # Home Manager has reloaded user systemd units for this generation.
  home.activation.sops-nix = lib.mkForce (config.lib.dag.entryAfter ["reloadSystemd"] ''
    if env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" PATH="${pkgs.systemd}/bin:$PATH" ${pkgs.systemd}/bin/systemctl --user list-unit-files | ${pkgs.gnugrep}/bin/grep -q '^sops-nix\.service'; then
      env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" PATH="${pkgs.systemd}/bin:$PATH" ${pkgs.systemd}/bin/systemctl restart --user sops-nix.service
    fi
  '');

  # ── Zsh ───────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable               = true;
    autocd               = true;
    autosuggestion.enable      = true;
    syntaxHighlighting.enable  = true;
    history = {
      size       = 10000;
      save       = 10000;
      ignoreDups = true;
      share      = true;
    };
  };
}
