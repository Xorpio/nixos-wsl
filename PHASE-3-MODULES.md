# Phase 3 - Shared Modules Reference

## Overview

Five reusable home-manager modules have been created to provide composable, machine-agnostic configuration for all machines in the NixOS setup.

## Modules Created

### 1. **modules/shell/default.nix** (3,978 bytes, 146 lines)

**Purpose**: Configure shell (zsh/bash) with aliases and environment variables.

**Key Features**:
- Default shell selection (zsh or bash)
- Pre-configured aliases (ls, grep, etc.)
- Environment variables for common tools
- Composable via `additionalAliases` and `additionalEnvironmentVariables`
- Zsh-specific: history management, smart options, prompt configuration
- WSL-compatible (no X11 assumptions)

**Configuration Options**:
```nix
modules.shell = {
  enable = true;
  defaultShell = "zsh";  # or "bash"
  aliases = { /* defaults */ };
  additionalAliases = { /* machine-specific */ };
  environmentVariables = { /* defaults */ };
  additionalEnvironmentVariables = { /* machine-specific */ };
  sessionVariables = { /* override */ };
  initExtra = ""; # extra shell init code
  promptInit = ""; # custom prompt
};
```

**Machine-Specific Usage Example**:
```nix
modules.shell.additionalAliases = {
  work = "cd ~/projects/work";
  nix-rebuild = "sudo nixos-rebuild switch --flake .";
};
```

---

### 2. **modules/neovim/default.nix** (5,840 bytes, 219 lines)

**Purpose**: Configure Neovim with comprehensive plugin suite and Lua setup.

**Key Features**:
- 26+ pre-configured plugins (telescope, treesitter, lsp, etc.)
- Vi/vim/vimdiff aliases
- Lua configuration support with sensible defaults
- Performance optimizations (disable unused built-in plugins)
- Colorscheme configuration (gruvbox default)
- Home-manager integration
- Extensible via `additionalPlugins` and `luaConfig`

**Included Plugins**:
- Navigation: telescope, which-key
- Syntax: nvim-treesitter, treesitter-context
- LSP: nvim-lspconfig, cmp-nvim-lsp, nvim-cmp
- Snippets: vim-vsnip
- File explorer: nvim-tree
- Git: vim-fugitive, gitsigns
- UI: lualine, gruvbox, indent-blankline, web-devicons
- Editing: vim-surround, vim-commentary, vim-repeat, vim-eunuch

**Configuration Options**:
```nix
modules.neovim = {
  enable = true;
  package = pkgs.neovim;
  viAlias = true;
  vimdiffAlias = true;
  colorscheme = "gruvbox";
  performanceOptimizations = true;
  plugins = [ /* defaults */ ];
  additionalPlugins = [ /* machine-specific */ ];
  extraConfig = ""; # Vimscript config
  luaConfig = ""; # Lua config block
};
```

**Machine-Specific Usage Example**:
```nix
modules.neovim.additionalPlugins = with pkgs.vimPlugins; [
  nvim-dap  # debugging support
  nvim-dap-ui
];
modules.neovim.luaConfig = ''
  -- Custom keymaps for work environment
  vim.keymap.set('n', '<leader>tc', ':Telescope commands<CR>')
'';
```

---

### 3. **modules/git/default.nix** (5,247 bytes, 214 lines)

**Purpose**: Configure git with sensible defaults, aliases, and per-machine overrides.

**Key Features**:
- Per-machine user name and email configuration
- 16+ pre-configured aliases (st, co, br, ci, etc.)
- Global gitignore with 200+ patterns (IDE, dependencies, environment)
- Rebase-by-default pull strategy
- Automatic fetch pruning
- Auto-stash during rebase
- Color and visual improvements
- Performance-optimized diff algorithm (histogram)

**Configured Aliases**:
- `st` = status
- `co` = checkout
- `br` = branch
- `ci` = commit
- `unstage` = reset HEAD --
- `last` = log -1 HEAD
- `visual` = log --graph --oneline --all
- `amend` = commit --amend --no-edit
- `clean-branches` = removes merged branches
- And more...

**Configuration Options**:
```nix
modules.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";
  aliases = { /* defaults */ };
  additionalAliases = { /* machine-specific */ };
  defaultBranch = "main";
  ignoreGlobal = ""; # default patterns
  pullRebase = true;
  fetchPrune = true;
  rebaseAutoStash = true;
  colorUi = "auto";
  extraConfig = { /* additional config */ };
};
```

**Machine-Specific Usage Example**:
```nix
modules.git = {
  enable = true;
  userName = "Brady Xorpio";
  userEmail = "brady@example.com";
  additionalAliases = {
    work-branch = "checkout -b work/$(date +%Y-%m-%d)";
  };
  extraConfig = {
    user.signingkey = "YOUR_GPG_KEY_ID";
    commit.gpgsign = true;
  };
};
```

---

### 4. **modules/dev-tools/default.nix** (5,389 bytes, 190 lines)

**Purpose**: Provide essential development tools in a modular, configurable way.

**Key Features**:
- Core tools: git, curl, wget
- Search: ripgrep (rg), fd, jq
- Modern ls replacement: eza
- Viewers: bat, less, man-pages
- Modular enable flags (includeCore, includeSearch, includeLs, includeViewers)
- Convenient aliases (ls → eza, cat → bat, grep → rg)
- Environment variables for each tool
- Helper configuration files (.ripgreprc, .fdrc)
- Informational notes for users

**Configuration Options**:
```nix
modules.dev-tools = {
  enable = true;
  includeCore = true;     # git, curl, wget
  includeSearch = true;   # ripgrep, fd, jq
  includeLs = true;       # eza
  includeViewers = true;  # bat, less, man-pages
  tools = [ /* defaults */ ];
  additionalTools = [ /* machine-specific */ ];
  enableAliases = true;
  batTheme = "gruvbox-dark";
};
```

**Machine-Specific Usage Example**:
```nix
modules.dev-tools.additionalTools = with pkgs; [
  nodejs
  python311
  rust
];
```

---

### 5. **modules/sops/default.nix** (8,930 bytes, 289 lines)

**Purpose**: Integrate sops-nix for secure secrets management with per-machine support.

**Key Features**:
- Age encryption support (modern, recommended)
- GPG encryption support (legacy)
- Per-machine secrets directory support
- Helper script for sops operations (edit, view, create, encrypt, decrypt, rotate)
- Comprehensive documentation and README
- Home-manager integration
- Configuration templates
- Secrets activation hooks

**Included Helper Commands**:
- `sops-helper edit FILE` - Edit secrets file
- `sops-helper view FILE` - View secrets (read-only)
- `sops-helper create FILE` - Create new secrets file
- `sops-helper encrypt FILE` - Encrypt plain file
- `sops-helper decrypt FILE` - Decrypt secrets file
- `sops-helper rotate FILE` - Rotate keys

**Configuration Options**:
```nix
modules.sops = {
  enable = true;
  defaultSopsFormat = "yaml";  # yaml, json, xml, ini, toml
  secretsDir = /etc/sops-nix/secrets;
  enableManagement = true;
  
  # Age encryption (default)
  age = {
    keyFile = ~/.config/sops/age/keys.txt;
    rules = [ /* encryption rules */ ];
  };
  
  # GPG encryption (alternative)
  gnupg = {
    enable = false;
    keyId = null;
  };
  
  managedSecrets = { /* shared secrets */ };
  additionalSecrets = { /* machine-specific */ };
};
```

**Machine-Specific Usage Example**:
```nix
modules.sops = {
  enable = true;
  secretsDir = /etc/sops-nix/secrets-daf-laptop;
  age.keyFile = ~/.config/sops/age/daf-laptop.txt;
  managedSecrets = {
    "github_token" = {
      sopsFile = ../../secrets/daf-laptop/secrets.yaml;
      key = "github.token";
      owner = "user";
      mode = "0400";
    };
  };
};
```

---

## Design Principles

### 1. **Composability**
Each module provides a base configuration that can be extended per-machine without duplication:
- `modules.shell.additionalAliases` merges with defaults
- `modules.neovim.additionalPlugins` appends to defaults
- `modules.git.additionalAliases` merges with defaults
- `modules.dev-tools.additionalTools` appends to defaults
- `modules.sops.additionalSecrets` merges with managed secrets

### 2. **Consistency**
All modules follow home-manager conventions:
- `{ config, options, lib, pkgs, ... }:` signature
- `options.modules.{name}` namespace
- `mkEnableOption` for toggles
- `mkOption` with `type`, `default`, `description`
- `config = mkIf config.modules.{name}.enable { ... }`
- `recursiveUpdate` for merging configurations

### 3. **Independence**
No hard dependencies between modules:
- Each can be enabled/disabled separately
- Can be imported in any order
- No circular references
- Ready for selective machine use

### 4. **Extensibility**
Every module supports machine-specific additions:
- "additional" options for extending defaults
- Extra configuration options for custom setup
- Helper scripts where appropriate
- Documentation for common tasks

---

## Usage in Per-Machine home.nix

```nix
{ config, options, lib, pkgs, ... }:

{
  imports = [
    ../../modules/shell
    ../../modules/neovim
    ../../modules/git
    ../../modules/dev-tools
    ../../modules/sops
  ];

  # Enable and configure modules
  modules = {
    shell = {
      enable = true;
      additionalAliases.work = "cd ~/projects/work";
    };
    
    neovim = {
      enable = true;
      colorscheme = "gruvbox";
    };
    
    git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your@email.com";
    };
    
    dev-tools.enable = true;
    
    sops = {
      enable = true;
      secretsDir = /etc/sops-nix/secrets-mylaptop;
    };
  };

  # Other home-manager configuration...
  home.stateVersion = "23.11";
}
```

---

## Next Steps

These modules are ready to be imported into per-machine home.nix configurations (Phase 4 - Tasks 5.1-5.4).

They provide:
- ✅ Reusable shell configuration
- ✅ Consistent Neovim setup with plugins
- ✅ Git configuration with per-machine overrides
- ✅ Common development tools
- ✅ Secrets management infrastructure

Ready for Phase 4: Per-Machine Home Configurations
