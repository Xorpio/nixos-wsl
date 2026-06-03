# Squad Routing — nixos-wsl

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Architecture/Nix strategy | Tony Stark (Lead) | Flake design, module composition strategy, design reviews |
| Flake/module implementation | Rocket Raccoon (Backend) | flake.nix structure, modules, system.nix, sops integration |
| home-manager/editor config | Wanda Maximoff (Frontend) | neovim setup, home.nix files, shell config, user environment |
| Specs/requirements validation | Bruce Banner (Tester) | Spec writing, test scenarios, validation, edge case analysis |
| Session logging | Scribe | Automatic — never needs routing |
| Work queue monitoring | Ralph | GitHub issues, PRs, backlog management |

## Routing Rules

1. **Named agent:** If user names an agent, route directly. Example: "Rocket, set up the flake"
2. **"Team, ...":** Fan-out to all relevant agents in parallel as `mode: "background"`
3. **Architecture questions:** Tony Stark (use sync for approval gates, background for review)
4. **Implementation:** Rocket (Nix) or Wanda (home-manager/neovim) based on scope
5. **Validation:** Bruce Banner (background) — writes specs, validates implementations
6. **Session/state:** Scribe (background, fire-and-forget, runs automatically after substantial work)
7. **Eager dispatch:** Spawn all agents who could usefully start work now, including anticipatory downstream work

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign correct `squad:{member}` label | Tony Stark (Lead) |
| `squad:tonystark` | Architecture decision or design question | Tony Stark |
| `squad:rocketraccoon` | Flake/module implementation | Rocket Raccoon |
| `squad:wandamaximoff` | home-manager/neovim config work | Wanda Maximoff |
| `squad:brucebanner` | Spec validation or testing | Bruce Banner |

## Blocking Modes

**Sync (blocking — use sparingly):**
- Tony's architecture decisions when user is waiting for approval
- User asks a direct question and needs immediate answer

**Background (default — use for all implementation work):**
- Implementation tasks (all team members)
- Spec writing/validation
- Session logging
- Work monitoring
- Follow-up work chains

## Parallel Fan-Out Example

**User:** "Team, set up the core flake structure"

**Dispatch (all at once, all background):**
```
🏗️  Tony Stark (sync first) — Review flake architecture draft, approve direction
    ↓ (after approval)
🔧 Rocket Raccoon (background) — Build flake.nix with inputs and outputs
⚛️  Wanda Maximoff (background) — Prepare home-manager config structure
🧪 Bruce Banner (background) — Write test scenarios for flake evaluation
📋 Scribe (background) — Log decisions and track progress
```

**Result:** All independent work starts immediately. Rocket doesn't wait for Wanda. Tests don't wait for implementation.
