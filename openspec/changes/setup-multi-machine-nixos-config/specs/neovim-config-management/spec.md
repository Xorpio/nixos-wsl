## ADDED Requirements

### Requirement: Neovim configuration lives in repo
Neovim configuration (Lua files, plugins, settings) SHALL be stored in `nvim-config/` directory within the repo, separate from Nix package management.

#### Scenario: Configuration directory structure
- **WHEN** developer examines `nvim-config/`
- **THEN** it contains standard Neovim directory layout: `init.lua`, `plugin/`, `lua/`, `ftplugin/`, etc.

#### Scenario: Lua files are directly editable
- **WHEN** developer edits `nvim-config/lua/config.lua`
- **THEN** changes are applied immediately without requiring a Nix rebuild (for development)

### Requirement: Nix manages Neovim packages and dependencies
The `modules/neovim/` directory SHALL declare Neovim itself and all plugins as Nix dependencies.

#### Scenario: Plugin list declared in Nix
- **WHEN** user wants to add a new plugin (e.g., telescope)
- **THEN** it is declared in `modules/neovim/default.nix` as a Nix package

#### Scenario: Consistent plugin versions across machines
- **WHEN** `flake.lock` is committed
- **THEN** all three machines install the exact same version of Neovim and all plugins

### Requirement: Neovim config is symlinked to user home
Home-manager SHALL symlink `nvim-config/` to `~/.config/nvim/` on each machine.

#### Scenario: Config is available at standard location
- **WHEN** Neovim starts
- **THEN** it finds configuration at `~/.config/nvim/` (via symlink from repo)

#### Scenario: Changes to repo reflect in editor
- **WHEN** developer commits a change to `nvim-config/`
- **THEN** after pulling and rebuilding home-manager, the editor has the new configuration

### Requirement: Machine-specific Neovim overrides are possible
Individual machines MAY override specific Neovim settings in their `home.nix` if needed, while sharing the base config.

#### Scenario: Machine-specific colorscheme
- **WHEN** home-desktop wants a different colorscheme than work machines
- **THEN** home-desktop's `home.nix` can override the colorscheme without affecting daf-laptop or centric-laptop

### Requirement: Shared Neovim config works identically on all machines
Given identical `flake.lock` and repo state, Neovim configuration SHALL be identical across daf-laptop, centric-laptop, and home-desktop.

#### Scenario: Same init.lua everywhere
- **WHEN** all three machines pull the same commit
- **THEN** all three have the same `~/.config/nvim/init.lua` via symlink
