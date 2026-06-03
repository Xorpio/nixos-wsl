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

## Governance

- All meaningful architectural changes require Tony Stark approval
- Implementation decisions owned by implementers; Tony reviews
- Specs validated by Bruce Banner; implementations must meet spec requirements
- Session memory maintained by Scribe append-only pattern
