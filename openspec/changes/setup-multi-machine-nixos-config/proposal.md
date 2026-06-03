## Why

Managing multiple machines (Daf work laptop, Centric work laptop, home desktop) with consistent configurations is error-prone when done manually. Using Nix flakes with home-manager and sops-nix creates a reproducible, version-controlled setup that can be deployed to multiple WSL instances while keeping machine-specific configurations separate and secrets secure.

## What Changes

- **Flake-based configuration**: Establish a single `flake.nix` as the source of truth for all three machines
- **Multi-machine setup**: Create per-machine configurations in `hosts/{daf-laptop,centric-laptop,home-desktop}/` with separate system and home-manager configs
- **Shared modules**: Build reusable modules (neovim, shell, git, dev tools) that can be composed across all machines
- **Neovim integration**: Include Neovim configuration (both Nix package management and Lua plugin files) in the repo for consistent editor setup
- **Encrypted secrets**: Set up sops-nix with per-machine secret files (encrypted, committed to git; keys stay local) for machine-specific credentials
- **Deployment workflow**: Establish `home-manager switch` for user environment changes and `nixos-rebuild switch` for system-level changes

## Capabilities

### New Capabilities

- `flake-multi-machine-setup`: Establish a Nix flake structure that manages three separate NixOS WSL instances with a single lock file
- `home-manager-user-environment`: Manage user-level configuration (shell, editor, dev tools, dotfiles) via home-manager across all machines
- `neovim-config-management`: Include and version-control Neovim configuration (Lua, plugins, settings) in the repo with reproducible builds
- `encrypted-machine-secrets`: Set up sops-nix to encrypt and manage per-machine secrets (e.g., API keys, SSH keys) with local key files
- `shared-configuration-modules`: Create reusable Nix modules (neovim, shell, git) that can be composed across all machines with machine-specific overrides

### Modified Capabilities

(None - this is a greenfield setup)

## Impact

- Creates new directory structure: `hosts/`, `modules/`, `nvim-config/`, `secrets/`
- Introduces new tooling: sops-nix for secret management
- Establishes deployment commands: `home-manager switch --flake .#user@hostname` and `nixos-rebuild switch --flake .#hostname`
- All three WSL instances will be configured from this single repo
- Requires user SSH keys and sops keys to be set up locally on each machine
