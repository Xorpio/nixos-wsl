{ pkgs, ... }:
{
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
};
