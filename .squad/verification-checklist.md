# Home-Manager Package Verification Checklist

**Change:** `add-dev-tools-and-vim-config`
**Packages:** taskwarrior (v3), tasksh, taskwarrior-tui, neovim
**Vim config:** line numbers via `programs.vim.settings.number = true`
**Last updated:** 2026-06-04

Run this checklist after each `nixos-rebuild switch` or `home-manager switch` deployment.
Mark each item ✅ (pass) or ❌ (fail) as you go.

---

## 1. Package Presence Checks

Confirm every package is in PATH and responds to a version query.

```bash
# Taskwarrior v3
which task
task --version
# Expected: "task X.Y.Z" where X = 3

# Tasksh
which tasksh
tasksh --version
# Expected: version string printed without error

# Taskwarrior TUI
which taskwarrior-tui
taskwarrior-tui --version
# Expected: version string printed without error

# Neovim
which nvim
nvim --version
# Expected: "NVIM vX.Y.Z" on first line

# Vim (for config verification later)
which vim
vim --version | head -1
# Expected: VIM version string
```

Checklist:
- [ ] `task` found in PATH
- [ ] `task --version` prints 3.x
- [ ] `tasksh` found in PATH
- [ ] `tasksh --version` exits 0
- [ ] `taskwarrior-tui` found in PATH
- [ ] `taskwarrior-tui --version` exits 0
- [ ] `nvim` found in PATH
- [ ] `nvim --version` prints NVIM vX.Y.Z
- [ ] `vim` found in PATH

---

## 2. Package Functionality Tests

Quick hands-on tests. Each should take under 30 seconds.

### Taskwarrior
```bash
# Add a test task, list it, then delete it
task add "Verification test task"
task list
task 1 delete
# Confirm: "y" to delete prompt — task is removed
task list
# Expected: "No matches." or empty list
```
- [ ] `task add` accepted input
- [ ] `task list` showed the test task
- [ ] `task delete` removed it cleanly

### Tasksh
```bash
# Launch the taskwarrior shell and exit immediately
tasksh
# Inside tasksh:
#   Type: list   → should show task list (or "No matches.")
#   Type: exit   → exits the shell
```
- [ ] `tasksh` launches without error
- [ ] `list` command works inside tasksh
- [ ] `exit` command exits cleanly

### Taskwarrior TUI
```bash
# Launch TUI, verify UI renders, then quit
taskwarrior-tui
# Expected: full-screen TUI appears
# Press: q   → exits the application
```
- [ ] TUI launches and renders a task management UI
- [ ] `q` exits without hanging

### Neovim
```bash
# Open a scratch file, write something, save, quit
nvim /tmp/nvim-verify.txt
# Inside nvim:
#   Press: i          → enters insert mode
#   Type: hello nvim  → text appears
#   Press: Esc        → returns to normal mode
#   Type: :wq         → saves and exits
cat /tmp/nvim-verify.txt
# Expected: "hello nvim"
rm /tmp/nvim-verify.txt
```
- [ ] `nvim` opens the file
- [ ] Insert mode works
- [ ] `:wq` saves and exits
- [ ] File content is correct after exit

---

## 3. Vim Configuration Verification

Confirm home-manager applied `programs.vim.settings.number = true`.

### Visual check
```bash
# Open any existing file in vim
vim /etc/os-release
# Expected: line numbers appear on left margin (1, 2, 3…)
# Exit with: :q
```
- [ ] Line numbers visible on left margin

### Inspect generated vimrc
```bash
# home-manager writes a vimrc; confirm number option is present
cat ~/.vimrc
# Expected: line containing "set number" or "number"

# Alternative location if not found above
cat ~/.vim/vimrc
```
- [ ] `set number` (or equivalent) is present in the generated vimrc

### Verify option inside vim
```bash
vim /etc/os-release
# Inside vim, type:
#   :set number?
# Expected output: "number" (confirming it is set)
# Exit: :q
```
- [ ] `:set number?` confirms `number` is active

---

## 4. Home-Manager State Validation

Confirm the home-manager generation was applied and contains expected content.

```bash
# Check current generation
home-manager generations | head -5
# Expected: most recent generation timestamp matches today's deployment

# Inspect packages in the current generation
home-manager packages | grep -E "task|nvim|vim"
# Expected: taskwarrior, tasksh, taskwarrior-tui, neovim all listed
```
- [ ] `home-manager generations` shows a recent generation
- [ ] `home-manager packages` lists taskwarrior
- [ ] `home-manager packages` lists tasksh
- [ ] `home-manager packages` lists taskwarrior-tui
- [ ] `home-manager packages` lists neovim

```bash
# Confirm neovim config symlink is in place (per architecture decision)
ls -la ~/.config/nvim
# Expected: symlink pointing to /root/nvim-config (or ~/nixos-wsl/nvim-config)
```
- [ ] `~/.config/nvim` exists as a symlink to `nvim-config/`

```bash
# Confirm the Nix store path is active
ls ~/.nix-profile/bin/ | grep -E "^(task|tasksh|taskwarrior|nvim|vim)$"
# Expected: each binary listed
```
- [ ] All 5 binaries (task, tasksh, taskwarrior-tui, nvim, vim) present in profile

---

## 5. Per-Machine Checklist

Run the above sections on each machine. Note any machine-specific differences.

### daf-laptop (user: daf)
**Deployment command:** `sudo nixos-rebuild switch --flake .#daf-laptop`

| Item | Status | Notes |
|------|--------|-------|
| `task --version` prints 3.x | | |
| `tasksh` launches | | |
| `taskwarrior-tui` launches | | |
| `nvim --version` succeeds | | |
| vim shows line numbers | | |
| home-manager generation updated | | |
| `~/.config/nvim` symlink correct | | |

### centric-laptop (user: centric)
**Deployment command:** `sudo nixos-rebuild switch --flake .#centric-laptop`

| Item | Status | Notes |
|------|--------|-------|
| `task --version` prints 3.x | | |
| `tasksh` launches | | |
| `taskwarrior-tui` launches | | |
| `nvim --version` succeeds | | |
| vim shows line numbers | | |
| home-manager generation updated | | |
| `~/.config/nvim` symlink correct | | |

### home-desktop (user: nixos)
**Deployment command:** `sudo nixos-rebuild switch --flake .#home-desktop`

| Item | Status | Notes |
|------|--------|-------|
| `task --version` prints 3.x | | |
| `tasksh` launches | | |
| `taskwarrior-tui` launches | | |
| `nvim --version` succeeds | | |
| vim shows line numbers | | |
| home-manager generation updated | | |
| `~/.config/nvim` symlink correct | | |

---

## Rollback Reference

If any check fails after deployment:

```bash
# Roll back the last home-manager generation
home-manager generations
# Note the previous generation ID, then:
home-manager activate /nix/var/nix/profiles/per-user/$USER/home-manager-<PREV-ID>

# Or roll back the full system:
sudo nixos-rebuild switch --rollback
```

Re-run this checklist after rollback to confirm previous state is restored.
