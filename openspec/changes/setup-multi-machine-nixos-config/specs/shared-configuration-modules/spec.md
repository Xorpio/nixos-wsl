## ADDED Requirements

### Requirement: Reusable modules in modules/ directory
Common configuration elements (shell, editor, dev tools, git) SHALL be packaged as reusable Nix modules in `modules/` and imported by individual machines.

#### Scenario: Shell module exists
- **WHEN** developer examines `modules/shell/`
- **THEN** it contains a Nix module (`default.nix`) declaring shell configuration (zsh setup, aliases, functions)

#### Scenario: Multiple machines import same module
- **WHEN** daf-laptop, centric-laptop, and home-desktop all need zsh
- **THEN** they all import `modules/shell/` rather than duplicating the configuration

### Requirement: Modules are composable
Modules SHALL accept parameters allowing machines to customize behavior without duplicating code.

#### Scenario: Module with overrideable defaults
- **WHEN** a machine imports `modules/shell/` but needs additional aliases
- **THEN** it can pass options to override or extend the default configuration

#### Scenario: Base configuration shared, machine-specific extension
- **WHEN** all machines need git configuration
- **THEN** `modules/git/` provides the base, and individual `home.nix` files can extend it

### Requirement: Modules declare their own dependencies
Each module in `modules/` SHALL declare its Nix package dependencies (e.g., zsh, git, neovim) via its own `default.nix`.

#### Scenario: Module declares shell package
- **WHEN** `modules/shell/default.nix` is evaluated
- **THEN** it includes `pkgs.zsh` as a dependency

#### Scenario: Dependencies are pulled from flake inputs
- **WHEN** a module needs a package
- **THEN** it references `pkgs` from the flake's nixpkgs input (ensuring version consistency)

### Requirement: Neovim configuration is a shared module
The Neovim configuration (plugins, settings, initialization) SHALL be provided by `modules/neovim/` and imported by all machines.

#### Scenario: All machines use same Neovim setup
- **WHEN** home-manager evaluates each machine's configuration
- **THEN** all three import `modules/neovim/` and receive identical editor setup (plugins, packages, etc.)

### Requirement: Shared modules support future expansion
Modules structure SHALL allow for new shared modules (e.g., `modules/dev-tools/`, `modules/cli-tools/`) without restructuring existing configuration.

#### Scenario: Adding a dev-tools module
- **WHEN** developer creates `modules/dev-tools/default.nix`
- **THEN** machines can optionally import it without affecting machines that don't

#### Scenario: Adding machine-specific module
- **WHEN** only home-desktop needs GUI tools
- **THEN** a `modules/gui/` can be created and imported only by that machine

### Requirement: Module defaults are sensible for WSL
Modules SHALL provide reasonable defaults appropriate for WSL environments (e.g., shell config compatible with WSL, no X11 dependencies unless requested).

#### Scenario: Shell module works on WSL
- **WHEN** shell module is applied on a WSL instance
- **THEN** configuration works without errors (no Windows-incompatible assumptions)
