## Context

Currently, each of the three machines (Daf work laptop, Centric work laptop, home desktop) running NixOS on WSL are independently configured. This creates maintenance burden—when a tool or setting is updated on one machine, it must be manually applied to others. There's no version control or reproducibility across machines. Secrets are managed ad-hoc locally, and Neovim configuration is not centralized.

## Goals / Non-Goals

**Goals:**
- Establish a single source of truth for all three machines via flakes
- Enable fast iteration on user environment (home-manager) without system-level rebuilds
- Provide reproducible, version-controlled setup across all three WSL instances
- Include Neovim configuration (Lua + Nix packages) in the repo
- Manage secrets securely with per-machine encryption (sops-nix)
- Support future expansion to bare-metal NixOS or additional machines

**Non-Goals:**
- Managing the NixOS system layer beyond minimal WSL setup
- GUI/desktop environment configuration (focus on CLI tools for WSL)
- Handling secrets that require external services (e.g., HashiCorp Vault)
- Orchestrating deployments across machines automatically

## Decisions

### 1. Single Flake for All Machines
**Decision**: Use one `flake.nix` with separate outputs for each machine (`nixosConfigurations.daf-laptop`, etc.) rather than per-machine flakes.

**Rationale**:
- Shared modules (neovim, shell, git) are easier to manage and update in one place
- Single lock file ensures dependency versions are consistent across machines
- Simpler mental model for maintenance
- Aligns with community best practices for multi-machine setups

**Alternatives considered**:
- Per-machine flakes: Would isolate machines but create duplication and version skew
- Monorepo with separate flakes per team: Overkill for three related personal machines

### 2. Home-Manager as Primary Tool for WSL
**Decision**: Use `home-manager switch --flake .#user@hostname` for day-to-day deployments, reserving `nixos-rebuild switch` for rare system-level changes.

**Rationale**:
- WSL doesn't expose traditional system configuration—user environment is what matters
- Faster iteration (no need to rebuild kernel, system packages)
- Cleaner permission model (no sudo required)
- If machines are ever migrated to bare-metal NixOS, home-manager remains the primary tool
- Separation of concerns: system config minimal/stable, user config frequent/varied

**Alternatives considered**:
- Always use nixos-rebuild: Works but requires sudo, slower for user-only changes, conflates system and user layers
- Ad-hoc shell scripts: Loses reproducibility

### 3. Separate Neovim Config Repository
**Decision**: Keep Nix package management for Neovim in `modules/neovim/default.nix` but store Lua config files in `nvim-config/` directory, with home-manager symlinked to `~/.config/nvim/`.

**Rationale**:
- Fast iteration: Edit Lua files, test immediately, no rebuild needed
- Nix still manages plugin versions (via `flake.lock`), ensuring reproducibility
- Clear separation: Nix = dependencies/packaging, Lua = editor behavior
- Mirrors community practice (most dotfiles repos follow this pattern)
- Easier to develop/test editor config independently

**Alternatives considered**:
- Everything in Nix (lua2nix): Theoretically pure but slow iteration, harder to debug
- Pure Lua in repo without Nix: Loses reproducibility and plugin version control

### 4. Per-Machine Encrypted Secrets
**Decision**: Each machine has its own `secrets/<hostname>/secrets.yaml` encrypted with sops-nix, with per-machine keys stored locally (not committed).

**Rationale**:
- Secrets are version-controlled but encrypted
- Per-machine keys allow revoking access by deleting a machine's key
- Local `.key` files never committed to git (via .gitignore)
- Straightforward to set up and rotate

**Alternatives considered**:
- External secret store (Vault, 1Password): Adds complexity and external dependencies
- Single shared key: Doesn't allow per-machine revocation
- Unencrypted secrets in repo: Security risk

### 5. Directory Structure with Shared Modules
**Decision**: Organize as `hosts/<hostname>/`, `modules/<function>/`, with shared configuration imported by each host.

**Rationale**:
- Clear separation: machine-specific (hosts) vs. shared (modules)
- Encourages code reuse across machines
- Easy to reason about what affects which machines
- Scales to additional machines or future services

**Alternatives considered**:
- Monolithic single configuration: Harder to track which setting affects which machine
- Per-machine monoliths: Duplicates shared config

### 6. Machine-Specific System Config, Shared User Config
**Decision**: System configuration (`system.nix`) can differ per machine, but user configuration (`home.nix`) primarily composes shared modules with optional per-machine overrides.

**Rationale**:
- System layer is minimal on WSL; machines are similar
- User tools and preferences are the primary customization point
- Allows machines to diverge in system layer if needed (different sudo groups, etc.) without affecting others
- Maximizes code reuse

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| **Flake complexity for newcomers** | Flakes have a learning curve; document the structure and provide examples |
| **Lock file conflicts on multi-user commits** | Use `flake.lock` merging practices; consider branch protection rules |
| **Secrets key rotation** | Create tooling/docs to safely rotate sops keys; keep procedures documented |
| **Divergence over time** | Regular code review to prevent machines from drifting; treat `modules/` as shared library |
| **WSL-specific issues** | WSL has quirks (Windows interop, filesystem); test changes on real WSL instances before committing |
| **Reproducibility dependent on flake inputs** | Upstream dependency changes can break builds; keep dependencies minimal and review updates regularly |

## Migration Plan

1. **Phase 1: Initialize repo structure**
   - Create `flake.nix` with basic inputs (nixpkgs, home-manager, sops-nix)
   - Create `hosts/`, `modules/`, `secrets/` directories
   - Create `hosts/<hostname>/` subdirectories for each machine

2. **Phase 2: Build base configurations**
   - Create `modules/shell/`, `modules/neovim/`, etc.
   - Create per-host `system.nix` and `home.nix` files
   - Start with minimal configurations to test the flake structure

3. **Phase 3: Secrets setup**
   - Generate sops keys for each machine (locally, not committed)
   - Create `secrets/<hostname>/secrets.yaml` encrypted files
   - Integrate sops-nix into home-manager

4. **Phase 4: Neovim integration**
   - Create `nvim-config/` with Lua configuration
   - Configure home-manager to symlink `nvim-config/` to `~/.config/nvim/`
   - Test on each machine

5. **Phase 5: Deploy to each machine**
   - For each machine: run `home-manager switch --flake .#user@hostname`
   - Validate configuration is applied correctly
   - Adjust and iterate as needed

## Open Questions

- **Username convention**: Should home-manager configs use a fixed username (e.g., "user") or match the system username? (Current plan: match system username)
- **Backup strategy**: Should there be a script to back up locally-stored sops keys? (Out of scope for now, but document manually)
- **Future scaling**: If more machines are added, is the current structure sufficient or should we add hierarchy? (Revisit if needed)
- **CI/CD for validation**: Should there be GitHub Actions to test flake builds? (Out of scope initially, consider later)
