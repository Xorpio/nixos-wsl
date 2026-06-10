{ pkgs, config, lib, ... }:
{
  imports = [ ./git.nix ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # ── Neovim ────────────────────────────────────────────────────────────────
  programs.neovim = {
    enable        = true;
    defaultEditor = true;   # sets EDITOR=nvim
    vimAlias      = true;   # `vim` → nvim
    viAlias       = true;   # `vi`  → nvim

    plugins = with pkgs.vimPlugins; [
      vim-nix   # syntax + indentation for Nix files
    ];

    extraConfig = ''
      " Line numbers
      set number
      set relativenumber

      " Tabs → 2 spaces
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent

      " Search
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch

      " UI
      set termguicolors
      set scrolloff=8
      set wrap
      set linebreak
      set signcolumn=yes

      " Clipboard (sync with system)
      set clipboard=unnamedplus

      " No swap / backup clutter
      set noswapfile
      set nobackup

      " Faster diagnostic updates
      set updatetime=250
    '';
  };

  # ── Taskwarrior ───────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    tasksh
    taskwarrior-tui
    yazi
  ];

  programs.taskwarrior = {
    enable  = true;
    package = pkgs.taskwarrior3;
    config = {
      dateformat              = "Y-M-D H:N";
      "dateformat.info"       = "Y-M-D H:N:S";
      "dateformat.annotation" = "Y-M-D H:N";
    };
  };

  # Write ~/.taskrc from sops secrets (secrets are defined per-host)
  # Override sops activation ordering: restart the user unit only after
  # Home Manager has reloaded user systemd units for this generation.
  home.activation.sops-nix = lib.mkForce (config.lib.dag.entryAfter ["reloadSystemd"] ''
    if env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" \
      PATH="${pkgs.systemd}/bin:$PATH" \
      ${pkgs.systemd}/bin/systemctl --user list-unit-files | ${pkgs.gnugrep}/bin/grep -q '^sops-nix\.service'; then
      env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" \
        PATH="${pkgs.systemd}/bin:$PATH" \
        ${pkgs.systemd}/bin/systemctl restart --user sops-nix.service
    fi
  '');

  home.activation.generateTaskrc = config.lib.dag.entryAfter ["writeBoundary" "sops-nix"] ''
    mkdir -p "$HOME/.config/task" 2>/dev/null || true
    cat > "$HOME/.taskrc" <<TASKRC
# Taskwarrior configuration with synced settings
dateformat=Y-M-D H:N
dateformat.info=Y-M-D H:N:S
dateformat.annotation=Y-M-D H:N

# Sync configuration (populated from secrets)
sync.server.url=$(cat "${config.sops.secrets."sync_server_url".path}")
sync.server.client_id=$(cat "${config.sops.secrets."sync_server_client_id".path}")
sync.encryption_secret=$(cat "${config.sops.secrets."sync_server_encryption_secret".path}")
TASKRC
    chmod 600 "$HOME/.taskrc"
  '';

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

