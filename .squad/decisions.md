# Squad Decisions — nixos-wsl

## Architecture Decisions

### Decision: Single Flake for All Machines
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved
**Rationale:** Single lock file ensures dependency versions are consistent across machines. Shared modules easier to manage. Aligns with community best practices.

### Decision: home-manager as Primary Deployment Tool
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved
**Rationale:** WSL doesn't expose traditional system config. home-manager is the right primary tool. Faster iteration, cleaner permission model.

### Decision: Separate Neovim Config (Lua + Nix)
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved
**Rationale:** Nix manages packages/plugins (reproducible). Lua in `nvim-config/` for fast iteration. Community best practice.

### Decision: Per-Machine Encrypted Secrets (sops-nix)
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved
**Rationale:** Each machine has own encrypted secrets file. Per-machine keys allow revocation. Secrets versioned but encrypted.

### Decision: Shared Modules Pattern
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved
**Rationale:** `modules/` directory contains reusable modules. Machines compose them. Maximizes code reuse and consistency.

---

## Team & Process Decisions

### Decision: Marvel Universe Casting
**Date:** 2026-06-03 (Niek)
**Status:** Active
**Rationale:** User requested Marvel universe. Names: Tony Stark (Lead), Rocket Raccoon (Backend), Wanda Maximoff (Frontend), Bruce Banner (Tester).

### Decision: Model Tier Strategy
**Date:** 2026-06-03 (Niek)
**Status:** Active
**Rationale:** Premium for architecture decisions (Tony), Standard for code/specs (implementers), Fast for mechanical ops (Scribe).

---

## Phase 1 Implementation — Flake Initialization

### Decision: Flake Output Structure (nixosConfigurations + homeConfigurations)
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved & Implemented
**Rationale:** Both `nixosConfigurations.{hostname}` and `homeConfigurations.{user}@{hostname}` coexist. `nixosConfigurations` allows rare system-level changes via `nixos-rebuild`; `homeConfigurations` is the primary day-to-day deployment interface (home-manager first).

### Decision: Inputs Pinning via flake.lock
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved & Implemented
**Rationale:** Single lock file ensures consistency across all three machines. Uses `nixpkgs-unstable` with specific dated inputs, pinned by `flake.lock` for reproducibility. Lock file is committed to git as source of truth.

### Decision: sops-nix Secrets Integration at Flake Input Level
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved & Implemented
**Rationale:** sops-nix added as flake input and integrated via `homeManagerModules.sops`. Per-machine secrets directories (`secrets/{hostname}/`) with encrypted YAML files and per-machine keys enforce security boundary.

### Decision: Module Composition at Host Level (not Top-Level Flake)
**Date:** 2026-06-03 (Tony Stark, Lead)
**Status:** Approved & Implemented
**Rationale:** Shared modules in `modules/{shell,neovim,git,dev-tools}/` are imported by each host's `home.nix` file, not composed at flake level. Keeps top-level flake clean as input/output coordinator. Enables per-host overrides without affecting others.

### Implementation Completion (Rocket Raccoon)
**Date:** 2026-06-03
**Deliverables:**
- ✅ `flake.nix` created with mkHostConfig helper function
- ✅ All three machines (daf-laptop, centric-laptop, home-desktop) declared as nixosConfigurations outputs
- ✅ Minimal WSL system config per machine (wsl.enable, defaultUser, hostName, stateVersion)
- ✅ home-manager integrated at nixosSystem level with homeConfigurations outputs
- ✅ `hosts/{hostname}/home.nix` placeholder files created
- ✅ Full directory structure: `modules/`, `secrets/`, `nvim-config/`
- ✅ sops-nix module available at homeManagerModules level (Phase 3 activation pending)

---

---

## Phase 4 & 5 Implementation — Per-Machine Configurations

### Decision: System Configuration Architecture
**Date:** 2026-06-03 (Rocket Raccoon, Implementer)
**Status:** Approved & Implemented
**Rationale:** Created minimal system.nix files for each machine instead of inline config in flake.nix. Separates concerns: flake.nix becomes a composition layer, system.nix files contain actual system configuration. Easier to maintain and understand per-machine configuration. Follows NixOS best practices for modular configuration.

**Implementation:**
- `hosts/daf-laptop/system.nix` - WSL config for user "daf"
- `hosts/centric-laptop/system.nix` - WSL config for user "centric"
- `hosts/home-desktop/system.nix` - WSL config for user "nixos"

Each file includes: system.stateVersion = "24.05", wsl.enable = true with correct defaultUser, networking.hostName, i18n.defaultLocale and time.timeZone, nix.settings.experimental-features for flake support.

### Decision: Home-Manager Module Integration
**Date:** 2026-06-03 (Rocket Raccoon, Implementer)
**Status:** Approved & Implemented
**Rationale:** All five shared modules imported and enabled in each home.nix. Modules are truly shared infrastructure (shell, neovim, git, dev-tools, sops). Enables consistent tooling across all machines. Makes machine-specific overrides clear and explicit. Per-machine customizations via module options.

**Implementation:**
All home.nix files import: shell, neovim, git, dev-tools, sops. Each machine enables modules with per-machine configuration (git userName/userEmail, defaultShell = "zsh", neovim with gruvbox colorscheme, dev-tools with all sub-features, sops for secrets management).

### Decision: Neovim Configuration Symlink (Task 5.4)
**Date:** 2026-06-03 (Rocket Raccoon, Implementer)
**Status:** Approved & Implemented
**Rationale:** Use mkOutOfStoreSymlink to symlink /root/nvim-config to ~/.config/nvim. Allows direct editing of Lua configuration files without rebuilding flake. Preserves all modules installed via home-manager. nvim-config/ directory contains user Lua files, not flake-managed. Developers can iterate on Lua config without touching Nix. Separation of concerns: Nix manages plugins, Lua manages configuration.

### Decision: No default.nix Files Needed (Tasks 4.4-4.6)
**Date:** 2026-06-03 (Rocket Raccoon, Implementer)
**Status:** Approved & Implemented
**Rationale:** mkHostConfig in flake.nix already handles full system composition. nixosConfigurations.{machine} output is sufficient for `nixos-rebuild switch --flake .#machine`. default.nix was a legacy pattern; flake outputs are the modern standard. Each host has system.nix and home.nix; no intermediate layer needed. Eliminates unnecessary indirection and file duplication.

### Decision: Updated flake.nix Structure
**Date:** 2026-06-03 (Rocket Raccoon, Implementer)
**Status:** Approved & Implemented
**Rationale:** Modified mkHostConfig to import system.nix instead of inline config. Removes duplication between inline config and system.nix files. mkHostConfig becomes a true composition layer. Clearer intent: flake.nix composes, system.nix configures. Easier to add new machines.

### Implementation Completion (Rocket Raccoon)
**Date:** 2026-06-03
**Deliverables:**
- ✅ `hosts/daf-laptop/system.nix` created
- ✅ `hosts/centric-laptop/system.nix` created
- ✅ `hosts/home-desktop/system.nix` created
- ✅ All home.nix files populated with module imports and per-machine configuration
- ✅ Neovim symlink configured (mkOutOfStoreSymlink to /root/nvim-config)
- ✅ Per-machine git configuration (userName, userEmail)
- ✅ All 5 modules enabled in each home.nix with per-machine customizations
- ✅ flake.nix updated to import system.nix files via mkHostConfig
- ✅ Tasks 4.1-4.6 and 5.1-5.4 complete (10 total)

---

## Governance

- All meaningful architectural changes require Tony Stark approval
- Implementation decisions owned by implementers; Tony reviews
- Specs validated by Bruce Banner; implementations must meet spec requirements
- Session memory maintained by Scribe append-only pattern
