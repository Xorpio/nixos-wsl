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

    # Helper documentation
    home.file.".config/nvim/PLUGINS.md" = {
      text = ''
        # Installed Neovim Plugins

        This is a reference guide for all installed plugins in this Neovim configuration.

        ## Navigation & Search
        - **telescope-nvim**: Fuzzy finder and telescope for files, grep, buffers, etc.
        - **telescope-fzf-native-nvim**: Native fzf sorter for telescope
        - **which-key-nvim**: Shows keybindings suggestions as you type

        ## Syntax & Highlighting
        - **nvim-treesitter**: Better syntax highlighting and code understanding
        - **nvim-treesitter-context**: Shows context of current scope (classes, functions, etc.)

        ## Language Server & Completion
        - **nvim-lspconfig**: Easy LSP setup for various languages
        - **cmp-nvim-lsp**: LSP completion source
        - **cmp-buffer**: Buffer completion source
        - **cmp-path**: Path completion source
        - **cmp-cmdline**: Command line completion source
        - **nvim-cmp**: Completion engine

        ## Snippets
        - **vim-vsnip**: Snippet engine
        - **vim-vsnip-integ**: Integration between vsnip and other plugins

        ## File Management
        - **nvim-tree-lua**: File explorer tree

        ## UI & Visual Enhancements
        - **lualine-nvim**: Fast and extensible statusline
        - **nvim-web-devicons**: Dev icons for various file types
        - **gruvbox-nvim**: Gruvbox color scheme
        - **indent-blankline-nvim**: Visual indentation guides

        ## Git Integration
        - **vim-fugitive**: Git commands in Vim
        - **gitsigns-nvim**: Git signs in sign column and inline diffs

        ## Text Editing Enhancements
        - **vim-surround**: Easy surrounding with quotes, brackets, etc.
        - **vim-commentary**: Quick commenting/uncommenting
        - **vim-repeat**: Repeat plugin commands with .
        - **vim-eunuch**: Unix file operations (move, delete, rename, etc.)

        ## Dependencies
        - **plenary-nvim**: Common lua functions
        - **nui-nvim**: UI components library

        ## Keybindings

        ### Telescope
        - `<leader>ff` - Find files
        - `<leader>fg` - Live grep
        - `<leader>fb` - Buffers
        - `<leader>fh` - Help tags

        ### Diagnostics (LSP)
        - `<leader>e` - Open floating diagnostic
        - `[d` - Go to previous diagnostic
        - `]d` - Go to next diagnostic

        ### File Explorer
        - `<leader>e` - Toggle file explorer (NvimTree)

        ### Window Navigation
        - `<C-h>` - Move to left window
        - `<C-j>` - Move to bottom window
        - `<C-k>` - Move to top window
        - `<C-l>` - Move to right window

        ### Buffers (from Lua config)
        - `<leader>bn` - Next buffer
        - `<leader>bp` - Previous buffer
        - `<leader>bd` - Delete buffer

        ## Adding New Plugins

        1. Add to `modules/neovim/default.nix` in the plugins list
        2. Configure in `nvim-config/plugin/` or `nvim-config/lua/` as needed
        3. Rebuild with home-manager

        ## Colorscheme

        Default: **gruvbox** (can be changed via module options)
      '';
    };
  };
}
