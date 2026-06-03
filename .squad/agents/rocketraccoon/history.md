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

## Work Session: 2026-06-03 (Phase 1)

**Date:** 2026-06-03  
**Session Type:** Phase 1 Implementation  
**Duration:** Background parallel execution

### Learnings
- **flake.nix with mkHostConfig Helper:** Built a reusable helper function that eliminates duplication across three machine configurations. Pattern: `mkHostConfig = hostname: hostConfig: nixpkgs.lib.nixosSystem { ... }` reduces boilerplate while keeping each machine's output clear and distinct.
- **WSL System Config Minimalism:** Kept system-level config intentionally minimal (wsl.enable, defaultUser, hostName, stateVersion) because WSL doesn't expose traditional system knobs. Primary work lives in home-manager at user level—this separation of concerns keeps code maintainable.
- **home-manager at nixosSystem Level:** Integrated home-manager as a nixosModule, enabling `homeConfigurations` outputs alongside `nixosConfigurations`. This dual-output pattern allows both "full system rebuild" (nixos-rebuild, rare) and "daily user config updates" (home-manager switch, common).
- **All Three Machines as First-Class Outputs:** daf-laptop, centric-laptop, home-desktop are all declarative nixosConfigurations. Each machine is independently deployable: `nixos-rebuild switch --flake .#daf-laptop` works identically across all three, courtesy of mkHostConfig abstraction.
- **sops-nix Integrated at Flake Input Level:** Added sops-nix as flake input and exposed `sops-nix.homeManagerModules.sops` to all machines. Per-machine secrets directories (`secrets/{hostname}/`) prepared. Actual encryption keys and YAML configs deferred to Phase 3 (when machines are live).

### Key Decision: home-manager as Primary Deployment Path
Endorsed by Tony: Day-to-day users run `home-manager switch --flake .#{user}@{hostname}`, not nixos-rebuild. This aligns with WSL's constraints and our architecture vision. System-level changes (rare) via `nixos-rebuild` remain available if needed.

### Implementation Checklist
- ✅ flake.nix created with mkHostConfig helper, all inputs (nixpkgs, home-manager, sops-nix)
- ✅ Three machines declared: daf-laptop, centric-laptop, home-desktop
- ✅ Minimal WSL system config per machine
- ✅ home-manager integration at nixosSystem level
- ✅ homeConfigurations outputs generated
- ✅ Directory structure: hosts/{hostname}/home.nix (3 files), modules/{shell,neovim,git,dev-tools}, secrets/{hostname}, nvim-config/
- ✅ sops-nix module available at homeManagerModules level

### Next Phase (Phase 2)
Will populate shared modules in `modules/` directory:
- `modules/shell/default.nix` — Shell environment (bash/zsh, aliases, functions)
- `modules/git/default.nix` — Git configuration (user, signing, remotes)
- `modules/dev-tools/default.nix` — Development tools (direnv, nix-direnv, etc.)
- `modules/neovim/default.nix` — Neovim packages and plugin management

Phase 2 will import these modules into each host's `home.nix` and test composition on target machines (lock file generation requires NixOS/Linux environment).

---

## Learnings Summary

(See work session above — Phase 1 complete)
