{ config, options, lib, pkgs, ... }:

with lib;

{
  options.modules.neovim = {
    enable = mkEnableOption "Neovim with common plugins and LSP configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.neovim;
      description = "Neovim package to use";
    };

    viAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Set up vi and vim aliases pointing to nvim";
    };

    vimdiffAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Set up vimdiff alias pointing to nvim";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs.vimPlugins; [
        # Navigation and search
        telescope-nvim
        telescope-fzf-native-nvim
        which-key-nvim

        # Treesitter for syntax highlighting
        nvim-treesitter
        nvim-treesitter-context

        # LSP and completion
        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        nvim-cmp

        # Snippets
        vim-vsnip
        vim-vsnip-integ

        # File explorer
        nvim-tree-lua

        # Visual enhancements
        lualine-nvim
        nvim-web-devicons
        gruvbox-nvim
        indent-blankline-nvim

        # Git integration
        vim-fugitive
        gitsigns-nvim

        # Editing enhancements
        vim-surround
        vim-commentary
        vim-repeat
        vim-eunuch

        # Other essentials
        plenary-nvim
        nui-nvim
      ];
      description = "List of vim plugins to install";
    };

    additionalPlugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional plugins to append to the default list (for machine-specific plugins)";
    };

    initLua = mkOption {
      type = types.str;
      default = "";
      description = "Custom Lua configuration";
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration (in Lua or Vimscript)";
    };

    luaConfig = mkOption {
      type = types.str;
      default = "";
      description = "Lua configuration block";
    };

    colorscheme = mkOption {
      type = types.str;
      default = "gruvbox";
      description = "Default colorscheme";
    };

    performanceOptimizations = mkOption {
      type = types.bool;
      default = true;
      description = "Enable basic performance optimizations";
    };
  };

  config = mkIf config.modules.neovim.enable {
    programs.neovim = {
      enable = true;
      package = config.modules.neovim.package;
      viAlias = config.modules.neovim.viAlias;
      vimdiffAlias = config.modules.neovim.vimdiffAlias;

      # Combine default and additional plugins
      plugins = config.modules.neovim.plugins ++ config.modules.neovim.additionalPlugins;

      # Performance optimizations
      extraConfig = ''
        ${optionalString config.modules.neovim.performanceOptimizations ''
          " Performance optimizations
          set nocompatible
          set hidden
          set cmdheight=1
          set updatetime=300
          set signcolumn=yes
        ''}
        
        " Basic settings
        set number
        set relativenumber
        set mouse=a
        set clipboard=unnamedplus
        set shiftwidth=2
        set tabstop=2
        set softtabstop=2
        set expandtab
        set smartindent
        set ignorecase
        set smartcase
        set incsearch
        set hlsearch
        set termguicolors
        
        " Colorscheme
        colorscheme ${config.modules.neovim.colorscheme}
        
        ${config.modules.neovim.extraConfig}
      '';

      # Lua configuration
      extraLuaConfig = ''
        -- Basic Lua setup
        ${optionalString config.modules.neovim.performanceOptimizations ''
          -- Disable some built-in plugins for better performance
          local disabled_built_ins = {
            "netrw",
            "netrwPlugin",
            "netrwSettings",
            "netrwFileHandlers",
            "gzip",
            "zip",
            "zipPlugin",
            "tar",
            "tarPlugin",
            "getscript",
            "getscriptPlugin",
            "vimball",
            "vimballPlugin",
            "2html_plugin",
            "logipat",
            "rrhelper",
            "spellfile_plugin",
            "matchit",
          }

          for _, plugin in pairs(disabled_built_ins) do
            vim.g["loaded_" .. plugin] = 1
          end
        ''}

        -- Set leader key
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        -- Basic keymaps
        local keymap = vim.keymap.set
        local opts = { noremap = true, silent = true }

        -- Better window navigation
        keymap("n", "<C-h>", "<C-w>h", opts)
        keymap("n", "<C-j>", "<C-w>j", opts)
        keymap("n", "<C-k>", "<C-w>k", opts)
        keymap("n", "<C-l>", "<C-w>l", opts)

        -- Better indenting
        keymap("v", "<", "<gv", opts)
        keymap("v", ">", ">gv", opts)

        -- Telescope setup (if available)
        local has_telescope, telescope = pcall(require, "telescope")
        if has_telescope then
          keymap("n", "<leader>ff", telescope.builtin.find_files, opts)
          keymap("n", "<leader>fg", telescope.builtin.live_grep, opts)
          keymap("n", "<leader>fb", telescope.builtin.buffers, opts)
          keymap("n", "<leader>fh", telescope.builtin.help_tags, opts)
        end

        -- LSP configuration (if available)
        local has_lspconfig, lspconfig = pcall(require, "lspconfig")
        if has_lspconfig then
          -- Diagnostics keybindings
          keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
          keymap("n", "[d", vim.diagnostic.goto_prev, opts)
          keymap("n", "]d", vim.diagnostic.goto_next, opts)
        end

        -- Nvim-tree setup (if available)
        local has_nvimtree, nvimtree = pcall(require, "nvim-tree")
        if has_nvimtree then
          keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
        end

        ${config.modules.neovim.luaConfig}
      '';
    };
  };
}
