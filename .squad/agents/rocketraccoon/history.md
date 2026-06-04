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

---

## Work Session: 2026-06-04 (Flake Validation & Blocker Investigation)

**Date:** 2026-06-04  
**Session Type:** Diagnostic / Blocker Resolution  
**Trigger:** `nix flake show` fails with "nix-command" experimental feature disabled

### Flake Structure: VALID ✅

Reviewed `flake.nix` manually. Structure is sound:

**Inputs:**
- `nixpkgs` → `github:nixos/nixpkgs/nixos-24.05`
- `home-manager` → `release-24.05` (follows nixpkgs)
- `sops-nix` → latest (follows nixpkgs)

**Outputs — nixosConfigurations (3 machines):**
| Machine | System | Default User |
|---|---|---|
| `daf-laptop` | x86_64-linux | daf |
| `centric-laptop` | x86_64-linux | centric |
| `home-desktop` | x86_64-linux | nixos |

**Outputs — homeConfigurations (standalone home-manager):**
- `daf@daf-laptop`
- `centric@centric-laptop`
- `nixos@home-desktop`

**Outputs — devShells:**
- `devShells.x86_64-linux.default` (nix + git + pre-commit)

Each machine uses `mkHostConfig` helper — no duplication. All three system.nix files already declare `nix.settings.experimental-features = [ "nix-command" "flakes" ]`. This is correct: once bootstrapped, the machine will enable flakes permanently.

### The Blocker Explained

`/etc/nix/nix.conf` (NixOS WSL) does NOT currently have `experimental-features = nix-command flakes` — that setting is managed by NixOS configuration and only applies after a `nixos-rebuild switch`. Before the first rebuild, you're running on the initial NixOS-WSL install which has a generated nix.conf without experimental features enabled.

### Workarounds (for Niek to run manually)

**Option A — One-shot, no config change (use this to validate):**
```bash
# In NixOS WSL, cd to the repo first
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl

nix flake show --extra-experimental-features 'nix-command flakes'
nix flake metadata --extra-experimental-features 'nix-command flakes'
```

**Option B — Permanent fix via user nix.conf (use this to unblock daily work):**
```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
# Now nix flake show and nix flake metadata work without flags
nix flake show
```

**Option C — Permanent fix via NixOS system (the right long-term answer):**  
Already in the repo! Each `hosts/{hostname}/system.nix` has:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```
After running `sudo nixos-rebuild switch --flake .#{hostname}` for the first time, this will be written to `/etc/nix/nix.conf` permanently. From that point, no flags needed.

### Recommended Bootstrap Order

1. Add `~/.config/nix/nix.conf` with `experimental-features = nix-command flakes` (Option B above) — **one command, unblocks everything immediately**
2. Verify the flake: `nix flake show` and `nix flake metadata`
3. Do the initial rebuild: `sudo nixos-rebuild switch --flake .#daf-laptop` (or the correct machine name)
4. After rebuild, the system-level nix.conf takes over — user nix.conf no longer needed

### Modules Confirmed Present

All modules referenced by home.nix files exist:
- `modules/shell/` ✅
- `modules/git/` ✅  
- `modules/dev-tools/` ✅
- `modules/neovim/` ✅
- `modules/sops/` ✅

### Next Steps

- Niek runs Option B to unblock himself immediately
- Run `nix flake show` to confirm outputs are visible
- Proceed to bootstrap first machine with `nixos-rebuild switch --flake .#{hostname}`

## 2026-06-04T09:15:00Z - Deployment Preparation Session
- Deployment artifacts created and documented
- Orchestration log generated
- Session log completed
- Pre-deployment checks passed

