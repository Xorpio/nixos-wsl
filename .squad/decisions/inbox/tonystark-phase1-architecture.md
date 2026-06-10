# Architecture Review — Phase 1: Flake Initialization
**Reviewed by:** Tony Stark (Lead)
**Date:** 2026-06-03
**Status:** Approved for Implementation

---

## Architectural Decisions

### 1. Flake Output Structure

**Decision: Option C — Both `nixosConfigurations` and `homeConfigurations`**

**Rationale:**
- `nixosConfigurations.{hostname}` aligns with the spec requirement (users may run `nixos-rebuild switch --flake .#daf-laptop` for rare system-level changes)
- `homeConfigurations.{user}@{hostname}` provides the primary deployment interface matching our home-manager-first philosophy
- Both coexist without friction; home-manager is the default day-to-day path

**Implementation Notes for Rocket:**
- Define both outputs in `flake.nix`
- Each machine gets: `nixosConfigurations.{hostname}` → system config, AND `homeConfigurations.{user}@{hostname}` → user config
- Document in README that day-to-day users should run `home-manager switch --flake .#{user}@{hostname}`, with `nixos-rebuild` reserved for system changes
- Ensure `flake show` displays both output types clearly

---

### 2. Inputs Pinning Strategy

**Decision: Pin to specific versions in `flake.lock` (latest at lock time, then reproducible)**

**Rationale:**
- Single lock file ensures consistency across all three machines—this is non-negotiable per our architecture
- Specific, dated versions (vs. unstable branches) are more reproducible and audit-friendly
- The lock file mechanism handles pinning; no need for date-specific branches

**Implementation Notes for Rocket:**
- Use `nixpkgs-unstable` **flake URL** (not branch constraint) pinned by lock file
- For home-manager and sops-nix: fetch from their official flakes (ensure they are flakes, not legacy)
- Run `nix flake update` only intentionally; document when/why locks are updated
- Lock file must be committed to git; this is the source of truth
- If reproducibility is critical for a specific dependency, use **`follows`** to align versions (e.g., home-manager follows nixpkgs)

---

### 3. Secrets Integration in Flake

**Decision: Integrate sops-nix directly in flake outputs, with per-machine secrets files and keys**

**Rationale:**
- Secrets belong in the reproducible build—sops-nix already integrates cleanly via flake inputs
- Per-machine keys (stored locally, not committed) enforce the security boundary we want
- This aligns with our existing decision: "Each machine has its own `secrets/<hostname>/secrets.yaml` encrypted with sops-nix"
- Avoids a separate manual setup step post-flake

**Implementation Notes for Rocket:**
- Add `sops-nix` as a flake input
- In each host's `home.nix`, conditionally import sops-managed secrets if the key exists
- Create `secrets/<hostname>/` directories (one per machine); store encrypted `secrets.yaml` files there
- Add `.gitignore` rule for `secrets/**/*.key` to prevent key commits
- Document key generation step: each machine must generate its own key once and store it locally (e.g., `/etc/sops-nix/keys.txt` or `~/.sops/keys/{hostname}.txt`)
- Sops integration should be optional in the flake—machines without keys should still build (with defaults)

---

### 4. Module Composition Pattern

**Decision: Mix approach — Shared modules imported by each host, composed at host level (not top-level flake)**

**Rationale:**
- Shared modules live in `modules/<function>/` (e.g., `modules/shell/`, `modules/neovim/`, `modules/git/`)
- Each host's `home.nix` explicitly imports the modules it needs (makes dependencies clear, easy to debug per-machine differences)
- Top-level flake remains the input/output coordinator; it does NOT compose modules for hosts
- This pattern scales: if a host needs a custom variant of a module, it can import + override without affecting others
- Aligns with community practice and our design doc: "shared modules pattern"

**Implementation Notes for Rocket:**
- Create `modules/` directory with subdirectories per feature (shell, neovim, git, etc.)
- Each module is a valid nix attribute set or function; `modules/shell/default.nix` is the entry point
- Each host's `home.nix` does: `imports = [ ../../modules/shell ../../modules/neovim ]; `
- In the top-level flake, define a helper function (optional) to construct a host config, but the actual module imports happen in the host files, not in the flake
- Module overrides stay in the host `home.nix` file using `config.programs.{...}.extraConfig` or nixpkgs config options (no monolithic flake helpers needed)
- Document: "If you need a host-specific variant, import the module and add overrides in your `home.nix`, don't duplicate the module"

---

## Caveats & Implementation Order

1. **Flake Complexity:** Flakes are not trivial for newcomers. Ensure the repo is well-commented and the README includes:
   - Directory structure diagram
   - Example: How to add a new machine
   - Troubleshooting section for common flake errors (e.g., "flake.lock conflicts")

2. **Lock File Merge Conflicts:** With all three machines using one lock file, developers must:
   - Pull before committing lock changes
   - Use `git merge --no-commit` for lock file merges and test locally before committing
   - Consider branch protection rules to prevent lock file conflicts

3. **Testing Each Machine:** The flake must be tested on each of the three machines to ensure outputs resolve correctly:
   - `nix flake show` should list all machines
   - `home-manager switch --flake .#user@daf-laptop` should work on daf-laptop (and similarly for others)
   - Secrets integration must be tested with actual keys on each machine

4. **Recommended Implementation Order (for Rocket Raccoon):**
   - **Step 1:** Create `flake.nix` with inputs (nixpkgs, home-manager, sops-nix), no outputs yet
   - **Step 2:** Create `hosts/`, `modules/`, `secrets/` directories with placeholder structures
   - **Step 3:** Define both `nixosConfigurations` and `homeConfigurations` outputs (minimal configs to test structure)
   - **Step 4:** Add sops-nix integration; create per-machine secrets directories
   - **Step 5:** Populate `modules/` with first few shared modules (shell, git)
   - **Step 6:** Test flake on one machine locally before rolling out to others

---

## Sign-Off

✅ **Approved for Phase 1 implementation.**
These decisions align with our existing architecture (as documented in design.md and decisions.md) and provide clear guidance for Rocket Raccoon's implementation. All four questions are resolved with specific, actionable recommendations.

**Next:** Rocket Raccoon proceeds with coding. Bruce Banner validates implementation against the spec.
