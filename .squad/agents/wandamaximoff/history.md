# Wanda Maximoff — Project History

## Context (Day 1)

**Owner:** Niek de Gooijer
**Project:** nixos-wsl — Multi-machine reproducible NixOS configuration
**Goal:** Centralize configuration for three WSL instances (Daf work laptop, Centric work laptop, home desktop) using Nix flakes, home-manager, and sops-nix.

**Architecture Decisions (from Tony):**
- home-manager as primary deployment tool (day-to-day updates)
- Separate `nvim-config/` directory with Lua files + `modules/neovim/` for Nix package management
- Shared configuration symlinked to ~/.config/nvim/ on each machine
- Per-machine overrides in machine-specific home.nix files

**Key Work:**
- Task 5: Integrate neovim config with home-manager (symlinks)
- Task 6: Initialize `nvim-config/` with Lua structure
- Task 7: Create `modules/neovim/default.nix` declaring plugins
- Machine-specific home.nix files with module composition

**Neovim Config Location:**
```
nvim-config/
├── init.lua
├── plugin/
├── lua/
│   ├── config/
│   └── keymaps/
└── ftplugin/
```

## Learnings

(None yet — awaiting implementation)

## 2026-06-04T09:20:30Z - Pre-Deployment Verification (Static Analysis)

**Status:** BLOCKED on live verification — deployment not yet executed (awaiting Rocket's "daf-laptop deployment complete" signal)

**Actions Taken:**

### Bug Found and Fixed: homeConfigurations Package Gap (Critical)

Performed static analysis of the entire configuration before deployment.

**Root Cause:** `taskwarrior3`, `tasksh`, `taskwarrior-tui`, `neovim`, `programs.vim.enable`, and `programs.vim.settings.number` were declared only inside the `nixosConfigurations` home-manager block in `flake.nix`. The `homeConfigurations` entries (used by the primary `home-manager switch` deployment path) imported only the per-machine `home.nix` files, which lacked these packages entirely.

**Impact (without fix):** Running the runbook's primary deployment path (`home-manager switch --flake .#daf@daf-laptop`) would produce a user environment with NO task tools and NO vim line numbers. All six verification checks on every machine would fail.

**Fix applied (commit 0697a69):**
- Moved `taskwarrior3`, `tasksh`, `taskwarrior-tui`, `neovim` into `home.packages` in each of:
  - `hosts/daf-laptop/home.nix`
  - `hosts/centric-laptop/home.nix`
  - `hosts/home-desktop/home.nix`
- Added `programs.vim.enable = true` and `programs.vim.settings.number = true` to all three
- Removed the now-redundant declarations from `flake.nix` (nixosConfigurations block)
- Removed dead `modules.neovim.enable = false` block from `home-desktop/home.nix` (neovim installed directly now)
- Removed unused `pkgs` binding from `mkHostConfig`

### Configuration Analysis Results (Post-Fix)

All three machines now have identical, correct configuration in `home.nix`:

| Package | nixpkgs-24.05 version | Status |
|---|---|---|
| `taskwarrior3` | v3.0.2 | ✅ Correct (v3.x as spec requires) |
| `tasksh` | v1.2.0 | ✅ Present |
| `taskwarrior-tui` | present | ✅ Present |
| `neovim` | present | ✅ Present |
| `programs.vim` | enabled | ✅ number = true |

### Predicted Verification Outcome (Post-Fix, Post-Deployment)

**daf-laptop, centric-laptop, home-desktop — ALL expected to PASS:**
- ✅ `task --version` → 3.0.2 (taskwarrior3 package)
- ✅ `tasksh --version` → exits 0
- ✅ `taskwarrior-tui --version` → exits 0
- ✅ `nvim --version` → NVIM vX.Y.Z
- ✅ `vim --version` → VIM - Vi IMproved
- ✅ vim line numbers → `set number` active via programs.vim.settings.number = true

### Outstanding: Live Verification Pending

Actual command execution on machines not possible from Windows environment. Awaiting Rocket's deployment completion signal to run live checks per `.squad/verification-checklist.md` Sections 1–4.

