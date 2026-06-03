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

## Governance

- All meaningful architectural changes require Tony Stark approval
- Implementation decisions owned by implementers; Tony reviews
- Specs validated by Bruce Banner; implementations must meet spec requirements
- Session memory maintained by Scribe append-only pattern
