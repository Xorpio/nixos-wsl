# Test Scenarios — add-dev-tools-and-vim-config

**Change:** Add taskwarrior, tasksh, taskwarrior-tui, neovim; enable vim line numbers  
**Machines:** daf-laptop (user: daf), centric-laptop (user: centric), home-desktop (user: nixos)  
**Primary deployment:** `home-manager switch` (via nixosConfigurations)  
**Author:** Bruce Banner — Tester  
**Date:** 2026-06-04

---

## 1. Pre-Deployment Validation

These tests run BEFORE any `nixos-rebuild switch` or `home-manager switch` is executed. If any of these fail, do not proceed with deployment.

---

### TEST-PRE-01 — Flake syntax is valid

**Expected behavior:** `nix flake check` completes without errors, confirming the flake.nix parses and evaluates correctly.

**How to run:**
```bash
nix flake check --no-build 2>&1
```

**Pass criteria:**
- Exit code is `0`
- No output lines containing `error:` or `warning: undefined variable`

**Failure recovery:**
1. Read the error message carefully — Nix errors include file and line number
2. Open `flake.nix` and fix the reported syntax error
3. Re-run `nix flake check --no-build` until it passes
4. Common causes: missing comma in package list, typo in attribute name

---

### TEST-PRE-02 — All four packages resolve in nixpkgs

**Expected behavior:** Each of the four new packages (`taskwarrior`, `tasksh`, `taskwarrior-tui`, `neovim`) resolves to a derivation in the pinned nixpkgs revision without build errors.

**How to run:**
```bash
nix eval .#nixosConfigurations.daf-laptop.config.home-manager.users.daf.home.packages \
  --apply 'pkgs: map (p: p.name) pkgs' 2>&1
```
Or individually:
```bash
nix eval nixpkgs#taskwarrior.name
nix eval nixpkgs#tasksh.name
nix eval nixpkgs#taskwarrior-tui.name
nix eval nixpkgs#neovim.name
```

**Pass criteria:**
- Each command returns a package name string (e.g., `"taskwarrior-3.x.x"`)
- No `error: attribute 'X' missing` output

**Failure recovery:**
1. If a package name is wrong, check the correct attribute name in nixpkgs: `nix search nixpkgs taskwarrior`
2. Note: taskwarrior v3 may be `taskwarrior3` in some nixpkgs revisions — verify attribute name
3. Update `flake.nix` with the correct attribute name and re-run TEST-PRE-01

---

### TEST-PRE-03 — vim module accepts settings.number

**Expected behavior:** The home-manager `programs.vim.settings.number` option is a valid boolean and accepted by the vim module in the pinned home-manager version.

**How to run:**
```bash
nix eval .#nixosConfigurations.daf-laptop.config.home-manager.users.daf.programs.vim.settings.number 2>&1
```

**Pass criteria:**
- Returns `true`
- No `error: The option ... does not exist` output

**Failure recovery:**
1. If the option path changed in home-manager 24.05, check available options: `man home-configuration.nix` or https://nix-community.github.io/home-manager/options.html
2. Alternative: use `programs.vim.extraConfig = "set number";` as a fallback
3. Update flake.nix accordingly and re-run TEST-PRE-01

---

### TEST-PRE-04 — All three machine configurations evaluate without errors

**Expected behavior:** The full NixOS system configuration for each machine evaluates (no build) without type errors or missing module options.

**How to run:**
```bash
nix eval .#nixosConfigurations.daf-laptop.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.centric-laptop.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.home-desktop.config.system.build.toplevel.drvPath
```

**Pass criteria:**
- Each command returns a `/nix/store/...drv` path string
- No `error:` output for any machine

**Failure recovery:**
1. Errors here are usually module conflicts or missing imports in `hosts/{hostname}/home.nix`
2. Run the failing machine in isolation to isolate the error
3. Check that `hosts/{hostname}/system.nix` files still exist and are valid

---

### TEST-PRE-05 — flake.lock is committed and up to date

**Expected behavior:** The `flake.lock` file is committed to git and no inputs are unlocked, ensuring reproducibility across machines.

**How to run:**
```bash
git status flake.lock
nix flake metadata --json | python3 -c "import sys,json; d=json.load(sys.stdin); print('locked' if d['locks'] else 'MISSING LOCKS')"
```

**Pass criteria:**
- `git status flake.lock` shows `nothing to commit` or `flake.lock` is listed as committed (not modified)
- All inputs in `flake.nix` appear in `flake.lock`

**Failure recovery:**
1. If `flake.lock` is missing or stale: `nix flake update` then `git add flake.lock && git commit -m "chore: update flake.lock"`
2. If you only want to lock without updating: `nix flake lock`

---

## 2. Post-Deployment Validation

Run these tests on EACH machine immediately after deployment. Tests are written for the logged-in user on each machine.

**Machine matrix:**
| Machine        | User     | Deploy command |
|---------------|----------|----------------|
| daf-laptop     | daf      | `home-manager switch --flake .#daf@daf-laptop` |
| centric-laptop | centric  | `sudo nixos-rebuild switch --flake .#centric-laptop` |
| home-desktop   | nixos    | `sudo nixos-rebuild switch --flake .#home-desktop` |

---

### TEST-POST-01 — taskwarrior is installed and is v3

**Expected behavior:** `task` command is on PATH and reports a 3.x version.

**How to run:**
```bash
which task
task --version
```

**Pass criteria:**
- `which task` returns a path under `/home/{user}/.nix-profile/bin/task` or `/nix/store/...`
- `task --version` outputs a version string starting with `3.`

**Failure recovery:**
- See TEST-FAIL-02 (package not found in PATH)
- Verify `taskwarrior` (not `taskwarrior3` or similar) is the correct attribute in your nixpkgs revision

---

### TEST-POST-02 — tasksh is installed and launches

**Expected behavior:** `tasksh` command is on PATH and enters an interactive prompt.

**How to run:**
```bash
which tasksh
echo "exit" | tasksh
```

**Pass criteria:**
- `which tasksh` returns a nix store or profile path
- `echo "exit" | tasksh` exits with code `0` and does not print `command not found`

**Failure recovery:**
- See TEST-FAIL-02
- `tasksh` requires `task` to be configured; if taskwarrior database is not initialized, `tasksh` may warn but should still launch

---

### TEST-POST-03 — taskwarrior-tui is installed

**Expected behavior:** `taskwarrior-tui` binary exists and reports a version.

**How to run:**
```bash
which taskwarrior-tui
taskwarrior-tui --version 2>&1 || true
```

**Pass criteria:**
- `which taskwarrior-tui` returns a valid path
- Binary is executable (no `permission denied`)

**Failure recovery:**
- See TEST-FAIL-02
- Note: `taskwarrior-tui` may require an initialized task database to display the TUI; a version flag or quick exit is sufficient for this test

---

### TEST-POST-04 — neovim is installed and functional

**Expected behavior:** `nvim` command is on PATH, reports a version, and can open a file non-interactively.

**How to run:**
```bash
which nvim
nvim --version | head -1
echo "" | nvim --headless -c 'echo "neovim ok"' -c 'qa' 2>&1
```

**Pass criteria:**
- `which nvim` returns a valid path
- `nvim --version` outputs a line starting with `NVIM v`
- Headless command exits with code `0`

**Failure recovery:**
- See TEST-FAIL-02
- If `nvim` conflicts with a system-level neovim, check PATH order: `echo $PATH | tr ':' '\n' | head -10`

---

### TEST-POST-05 — vim has line numbers enabled

**Expected behavior:** When vim opens a file, line numbers are visible on the left margin. This is the result of `programs.vim.settings.number = true` generating a `.vimrc` with `set number`.

**How to run:**
```bash
# Check .vimrc is generated and contains 'set number'
cat ~/.vimrc | grep -i "number"

# Visual check (non-interactive alternative):
echo -e "line1\nline2\nline3" > /tmp/testfile.txt
vim -c 'set number' -c 'redir @a | set number? | redir END | put a | w! /tmp/vimtest_out.txt | q!' /tmp/testfile.txt 2>/dev/null
grep "number" /tmp/vimtest_out.txt

# Cleanest check - just verify the generated vimrc
grep "set number" ~/.vimrc
```

**Pass criteria:**
- `~/.vimrc` exists and contains `set number` (home-manager generates this file)
- No `noset number` or `set nonumber` overrides present

**Failure recovery:**
- See TEST-FAIL-03 (vim config not applied)
- If `~/.vimrc` is absent: check `home-manager generations` to confirm the last switch succeeded

---

### TEST-POST-06 — home-manager generation reflects new configuration

**Expected behavior:** The active home-manager generation includes all new packages and vim configuration.

**How to run:**
```bash
home-manager generations | head -3
home-manager packages | grep -E "taskwarrior|tasksh|neovim"
```

**Pass criteria:**
- A new generation exists dated today
- `taskwarrior`, `tasksh`, `taskwarrior-tui`, and `neovim` all appear in the package list

**Failure recovery:**
- If today's generation is absent, the switch may have failed silently — check `journalctl -u home-manager-{user}.service`
- Roll back with `home-manager rollback` if the previous generation was stable

---

## 3. Cross-Machine Consistency Tests

Run AFTER all three machines have been deployed. The goal is to confirm that the single flake.lock pin produces identical package versions on all machines.

---

### TEST-CROSS-01 — taskwarrior version is identical across machines

**Expected behavior:** All three machines report the same taskwarrior version string, derived from the same nixpkgs pin.

**How to run (on each machine, collect output):**
```bash
task --version
```

**Pass criteria:**
- All three machines output the same version string (e.g., `3.x.x`)
- No machine shows a different major or minor version

**Failure recovery:**
- Version mismatch means one machine deployed from a different flake revision
- Check `git log --oneline -5` on the diverging machine to confirm it pulled latest
- Re-deploy with `git pull && sudo nixos-rebuild switch --flake .#hostname`

---

### TEST-CROSS-02 — neovim version is identical across machines

**Expected behavior:** All three machines report the same `NVIM vX.Y.Z` version.

**How to run (on each machine):**
```bash
nvim --version | head -1
```

**Pass criteria:**
- All three outputs are identical
- No machine shows a different NVIM version

**Failure recovery:**
- Same as TEST-CROSS-01: stale flake revision on one machine

---

### TEST-CROSS-03 — vim .vimrc is identical across machines

**Expected behavior:** home-manager generates the same `.vimrc` on all three machines since the configuration is defined centrally.

**How to run (on each machine):**
```bash
md5sum ~/.vimrc
# or
sha256sum ~/.vimrc
```

**Pass criteria:**
- All three machines produce the same checksum for `~/.vimrc`
- Content on all machines includes `set number`

**Failure recovery:**
- If checksums differ, one machine may have a local override or a stale generation
- Inspect with `diff <(ssh machine1 cat ~/.vimrc) <(ssh machine2 cat ~/.vimrc)`
- Re-deploy the diverging machine

---

### TEST-CROSS-04 — flake.lock is the same on all machines (source of truth)

**Expected behavior:** All machines deployed from the same git commit and therefore use the same `flake.lock`.

**How to run (on each machine, in the flake repo directory):**
```bash
git log --oneline -1
sha256sum flake.lock
```

**Pass criteria:**
- All machines show the same git commit hash
- `flake.lock` checksum is identical across machines

**Failure recovery:**
- If a machine is behind: `git pull` then re-deploy
- Never run `nix flake update` on a single machine without committing and syncing to all machines — this breaks reproducibility (violates the Single Flake decision)

---

### TEST-CROSS-05 — taskwarrior-tui version is identical across machines

**Expected behavior:** All three machines have the same `taskwarrior-tui` binary, from the same nixpkgs derivation.

**How to run (on each machine):**
```bash
taskwarrior-tui --version 2>&1 | head -1
# or: nix-store --query --deriver $(which taskwarrior-tui)
```

**Pass criteria:**
- All three machines report the same version or the same nix store derivation path prefix

**Failure recovery:**
- Same as TEST-CROSS-01

---

## 4. Edge Case Scenarios

---

### TEST-EDGE-01 — vim config doesn't apply (existing .vimrc conflict)

**Scenario:** User has a manually created `~/.vimrc` that home-manager cannot manage because it was created outside of nix.

**How to detect:**
```bash
# Check if .vimrc is owned by home-manager
home-manager packages | grep vim
ls -la ~/.vimrc
# If it's a symlink pointing into the nix store, it's managed correctly
# If it's a regular file, there may be a conflict
file ~/.vimrc
```

**Expected behavior:** home-manager overwrites unmanaged `.vimrc` on first switch; if a backup file exists (`~/.vimrc.backup`), the conflict was detected.

**Pass criteria:**
- `~/.vimrc` is either a nix-managed symlink or a home-manager-generated regular file containing `set number`
- No `error: Existing file '~/.vimrc' is in the way` in switch output

**Recovery steps:**
1. Back up existing vimrc: `cp ~/.vimrc ~/.vimrc.pre-nixos`
2. Remove the conflicting file: `rm ~/.vimrc`
3. Re-run `home-manager switch`
4. Verify `~/.vimrc` is now generated with `set number`

---

### TEST-EDGE-02 — Package binary not on PATH after deployment

**Scenario:** Packages are installed but not accessible because home-manager profile is not on PATH (common in fresh WSL setups).

**How to detect:**
```bash
echo $PATH | tr ':' '\n' | grep -E "nix|home-manager"
which task 2>&1
```

**Expected behavior:** `~/.nix-profile/bin` (or `/home/{user}/.nix-profile/bin`) is in PATH after login.

**Pass criteria:**
- `which task` does NOT return `command not found`
- PATH contains a nix-managed bin directory

**Recovery steps:**
1. Source the nix profile: `. ~/.nix-profile/etc/profile.d/nix.sh`
2. Or add to `~/.bashrc` / `~/.zshrc`: `export PATH="$HOME/.nix-profile/bin:$PATH"`
3. Log out and back in to reload environment
4. If using WSL: restart the WSL instance (`wsl --terminate <distro>` from Windows)

---

### TEST-EDGE-03 — taskwarrior-tui crashes on launch (missing task database)

**Scenario:** `taskwarrior-tui` launches but immediately crashes because no taskwarrior database exists yet (expected per design — no auto-initialization).

**How to detect:**
```bash
taskwarrior-tui 2>&1; echo "exit code: $?"
```

**Expected behavior:** Per design decision 4, taskwarrior is NOT auto-initialized. The TUI may display an error or empty state on first run — this is acceptable. The binary must be present and executable.

**Pass criteria:**
- Binary exists: `which taskwarrior-tui` succeeds
- If TUI errors on missing database, the error is about missing data (not missing binary)

**Recovery steps (user action, not a bug):**
1. Initialize taskwarrior database: `task version` (auto-initializes on first run)
2. Re-launch `taskwarrior-tui` — should now work

---

### TEST-EDGE-04 — neovim conflicts with vim alias

**Scenario:** Both `vim` and `nvim` are installed; a shell alias or symlink maps `vim` to one of them, causing unexpected behavior.

**How to detect:**
```bash
which vim
which nvim
vim --version | head -1
nvim --version | head -1
alias vim 2>/dev/null || true
type vim
```

**Expected behavior:** `vim` runs the home-manager-managed vim (with line numbers). `nvim` runs neovim. They are separate tools.

**Pass criteria:**
- `vim` and `nvim` resolve to different binaries
- `vim` shows Vi/Vim in version output
- `nvim` shows NVIM in version output
- No shell alias overrides `vim` to point to neovim (unless intentionally configured)

**Recovery steps:**
1. Check for aliases in `~/.bashrc`, `~/.zshrc`, `~/.profile`
2. If unintended alias exists, remove it and reload shell
3. If `vim` is missing but home-manager shows vim enabled, check `home-manager generations`

---

### TEST-EDGE-05 — Deployment fails mid-way (partial state)

**Scenario:** `nixos-rebuild switch` or `home-manager switch` is interrupted (network loss, disk full, Ctrl+C) leaving the system in a partial state.

**How to detect:**
```bash
home-manager generations | head -5
# Check if current generation is the expected one
nix-store --verify --check-contents 2>&1 | head -20
```

**Expected behavior:** Nix is transactional — either the full switch succeeds or it rolls back. Partial state is unusual but possible if the activation script fails.

**Pass criteria:**
- After recovery, `home-manager generations` shows either the new or the previous generation (not corrupted)

**Recovery steps:**
1. Re-run the deployment command — Nix will resume from cached derivations
2. If corrupted: `home-manager rollback` to go back to previous generation
3. For nixos-rebuild: `sudo nixos-rebuild switch --rollback`
4. Check disk space: `df -h /nix` — Nix store requires adequate space

---

## 5. Failure Scenarios

---

### TEST-FAIL-01 — `nix flake check` reports attribute missing

**Error message pattern:**
```
error: attribute 'taskwarrior' missing
```
or
```
error: attribute 'tasksh' missing
```

**Cause:** The nixpkgs revision pinned in `flake.lock` does not have the package under the expected attribute name.

**Detection:**
```bash
nix flake check --no-build 2>&1 | grep "error:"
nix search nixpkgs#taskwarrior 2>&1 | head -10
```

**Recovery:**
1. Find the correct attribute name: `nix search nixpkgs taskwarrior`
2. Update `flake.nix` with the correct name (e.g., `taskwarrior3` instead of `taskwarrior`)
3. Re-run `nix flake check --no-build`

---

### TEST-FAIL-02 — Package installed but binary not found in PATH

**Error message pattern:**
```
task: command not found
nvim: command not found
```

**Cause:** Either (a) the home-manager switch didn't complete, (b) PATH is not updated in current shell session, or (c) nix profile directory is missing from PATH.

**Detection:**
```bash
ls ~/.nix-profile/bin/ | grep -E "task|nvim|vim"
echo $PATH | tr ':' '\n'
home-manager generations | head -1
```

**Recovery:**
1. If binaries exist in `~/.nix-profile/bin/` but PATH is missing the directory: `. ~/.nix-profile/etc/profile.d/nix.sh`
2. If binaries don't exist: home-manager switch did not complete — re-run
3. Start a new shell session (new terminal) — PATH changes from home-manager only apply to new sessions

---

### TEST-FAIL-03 — vim line numbers not showing (`.vimrc` not generated)

**Error message pattern:** No error — vim simply opens without line numbers.

**Cause:** `programs.vim` module didn't generate `~/.vimrc`, or it was overridden.

**Detection:**
```bash
cat ~/.vimrc 2>/dev/null || echo "MISSING"
grep "number" ~/.vimrc 2>/dev/null || echo "number not configured"
home-manager packages | grep vim
```

**Recovery:**
1. Confirm `programs.vim.enable = true` is in `flake.nix` — check the vim block under `home-manager.users.{user}`
2. Check home-manager switch completed: `home-manager generations | head -1` should be today
3. If `~/.vimrc` exists but without `set number`, look for a conflicting `.vimrc` or local override
4. Run `home-manager switch` again and watch for any errors about the vim module

---

### TEST-FAIL-04 — `nixos-rebuild switch` fails on centric-laptop or home-desktop

**Error message pattern:**
```
error: builder for '/nix/store/...drv' failed with exit code 1
```
or
```
error: could not set permissions on '...'
```

**Cause:** Build failure, permission issue, or WSL-specific constraint.

**Detection:**
```bash
sudo nixos-rebuild switch --flake .#centric-laptop 2>&1 | tail -30
journalctl -u nixos-activation.service --since "5 minutes ago"
```

**Recovery:**
1. For build failures: check if the Nix cache has the derivations — packages may need to download
2. For permission errors in WSL: ensure running as the correct user with sudo
3. For WSL-specific failures: check that `wsl.enable = true` is in system.nix
4. Try `--show-trace` flag for more detailed error output: `sudo nixos-rebuild switch --flake .#centric-laptop --show-trace`

---

### TEST-FAIL-05 — Cross-machine version mismatch detected

**Error message pattern:** No error — versions just differ when compared.

**Cause:** One machine was rebuilt from a different git commit, or `nix flake update` was run on one machine without committing.

**Detection:**
```bash
# On diverging machine:
git log --oneline -3
sha256sum flake.lock
nix flake metadata --json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['locked']['lastModified'])"
```

**Recovery:**
1. On the diverging machine: `git pull origin main`
2. Re-deploy: `sudo nixos-rebuild switch --flake .#hostname`
3. Verify versions match: re-run TEST-CROSS-01 through TEST-CROSS-05
4. If someone ran `nix flake update` on just one machine, they must commit the updated `flake.lock` and all machines must pull and redeploy

---

## 6. Success Criteria Matrix

| Test ID | Description | Machine Scope | Pass Condition | Blocker? |
|---------|-------------|---------------|----------------|----------|
| TEST-PRE-01 | Flake syntax valid | All (once) | `nix flake check --no-build` exits 0 | ✅ YES — must pass before deploy |
| TEST-PRE-02 | All 4 packages resolve | All (once) | Each package name evaluates without error | ✅ YES |
| TEST-PRE-03 | vim.settings.number accepted | All (once) | Evaluates to `true` | ✅ YES |
| TEST-PRE-04 | All 3 machines evaluate | All (once) | All return `.drv` paths | ✅ YES |
| TEST-PRE-05 | flake.lock committed | All (once) | No uncommitted lock changes | ✅ YES |
| TEST-POST-01 | taskwarrior v3 installed | Per machine | `task --version` returns `3.x` | ✅ YES |
| TEST-POST-02 | tasksh installed | Per machine | `echo "exit" \| tasksh` exits 0 | ✅ YES |
| TEST-POST-03 | taskwarrior-tui installed | Per machine | `which taskwarrior-tui` succeeds | ✅ YES |
| TEST-POST-04 | neovim installed | Per machine | `nvim --version` shows `NVIM v` | ✅ YES |
| TEST-POST-05 | vim line numbers enabled | Per machine | `~/.vimrc` contains `set number` | ✅ YES |
| TEST-POST-06 | home-manager generation updated | Per machine | New generation dated today | ⚠️ WARNING |
| TEST-CROSS-01 | taskwarrior version identical | All 3 machines | Same version string everywhere | ✅ YES |
| TEST-CROSS-02 | neovim version identical | All 3 machines | Same `NVIM vX.Y.Z` everywhere | ✅ YES |
| TEST-CROSS-03 | .vimrc identical | All 3 machines | Same checksum everywhere | ✅ YES |
| TEST-CROSS-04 | Same git commit deployed | All 3 machines | Same commit hash and flake.lock | ✅ YES |
| TEST-CROSS-05 | taskwarrior-tui version identical | All 3 machines | Same version/derivation everywhere | ✅ YES |
| TEST-EDGE-01 | No .vimrc conflict | Per machine | home-manager owns `~/.vimrc` | ⚠️ WARNING |
| TEST-EDGE-02 | PATH includes nix profile | Per machine | `which task` succeeds in new shell | ✅ YES |
| TEST-EDGE-03 | taskwarrior-tui launchable | Per machine | Binary present; db error is acceptable | ⚠️ WARNING |
| TEST-EDGE-04 | vim and nvim are separate | Per machine | Different binaries, no alias conflict | ⚠️ WARNING |
| TEST-EDGE-05 | No partial deploy state | Per machine | Clean generation list | ✅ YES |

**Legend:**
- ✅ YES — Failure means the change is not correctly deployed; must be resolved before sign-off
- ⚠️ WARNING — Failure is informational; document and proceed but investigate if widespread

---

### Overall Sign-Off Conditions

The change `add-dev-tools-and-vim-config` is **ACCEPTED** when:

1. All `TEST-PRE-*` tests pass on at least one machine before deployment begins
2. All `TEST-POST-*` YES tests pass on **all three machines**
3. All `TEST-CROSS-*` tests pass (confirming consistency)
4. Any WARNING failures are documented with a reason they are acceptable

The change is **REJECTED** if:
- Any YES-blocker test fails on any machine after two recovery attempts
- Cross-machine version mismatch persists after re-deploying the diverging machine
- `vim` on any machine does not show line numbers (`programs.vim.settings.number = true` is a core spec requirement)
