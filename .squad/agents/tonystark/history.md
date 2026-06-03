# Tony Stark — Project History

## Context (Day 1)

**Owner:** Niek de Gooijer  
**Project:** nixos-wsl — Multi-machine reproducible NixOS configuration  
**Goal:** Centralize configuration for three WSL instances (Daf work laptop, Centric work laptop, home desktop) using Nix flakes, home-manager, and sops-nix.

**Key Decisions Made:**
- Single flake for all machines (not per-machine)
- home-manager as primary deployment tool (not nixos-rebuild)
- Separate neovim config repo with Nix package management
- Per-machine encrypted secrets (sops-nix)
- Shared modules approach for reusable config

**Capabilities to Implement:**
1. flake-multi-machine-setup
2. home-manager-user-environment
3. neovim-config-management
4. encrypted-machine-secrets
5. shared-configuration-modules

## Learnings

(None yet — awaiting implementation)
