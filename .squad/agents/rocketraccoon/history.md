# Rocket Raccoon — Project History

## Context (Day 1)

**Owner:** Niek de Gooijer
**Project:** nixos-wsl — Multi-machine reproducible NixOS configuration
**Goal:** Centralize configuration for three WSL instances (Daf work laptop, Centric work laptop, home desktop) using Nix flakes, home-manager, and sops-nix.

**Architecture Decisions (from Tony):**
- Single `flake.nix` manages all three machines with shared lock file
- Per-machine directories: `hosts/{daf-laptop,centric-laptop,home-desktop}/`
- Shared modules in `modules/{shell,neovim,git,dev-tools}/`
- sops-nix for encrypted per-machine secrets

**Key Directory Structure:**
```
nixos-wsl/
├── flake.nix (single source of truth)
├── hosts/{daf-laptop,centric-laptop,home-desktop}/
├── modules/{shell,neovim,git,dev-tools}/
├── nvim-config/
└── secrets/{daf-laptop,centric-laptop,home-desktop}/
```

**My Work:**
- Task 1: Initialize flake structure with inputs (nixpkgs, home-manager, sops-nix)
- Task 2-4: Build shared modules
- Task 5-6: Create per-machine system.nix and home.nix

## Learnings

(None yet — awaiting implementation)
