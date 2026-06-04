# Deployment Ready — nixos-wsl Configuration

**Status:** ✅ Flake configuration is validated and ready for deployment
**Last Updated:** 2026-06-04
**Commits:** Fixed taskwarrior v2 → v3, removed unimplemented nvim symlink checks

---

## Deployment Architecture

| Component | Location | Role |
|-----------|----------|------|
| **Flake Config** | `/mnt/c/Users/Niek.de.Gooijer/nixos-wsl` (this repo) | Configuration source |
| **daf-laptop** | Separate NixOS system (physical machine or WSL instance) | Deploy target 1 |
| **centric-laptop** | Separate NixOS system | Deploy target 2 |
| **home-desktop** | Separate NixOS system | Deploy target 3 |

Each target is a **separate NixOS environment** with its own `nix` and `nixos-rebuild` toolchain. The flake is deployed TO each, not run FROM this archlinux WSL.

---

## Pre-Deployment Checklist

- [x] Flake syntax validated
- [x] taskwarrior v3 configured (fixed from v2)
- [x] vim line numbers configured
- [x] neovim installed
- [x] tasksh and taskwarrior-tui included
- [x] home-manager integration complete
- [x] Git history clean (commits made)
- [ ] Nix installed on each target machine
- [ ] Each target machine has internet access for package downloads
- [ ] Each target has 2–5 GB free disk space

---

## Deployment Steps (Per Machine)

**Run these commands ON EACH TARGET MACHINE (daf-laptop, centric-laptop, home-desktop), not in the archlinux WSL.**

### Step 1: Access the Machine

**daf-laptop:**
```bash
# SSH, RDP, or local terminal on daf-laptop
ssh user@daf-laptop
```

**centric-laptop:**
```bash
ssh user@centric-laptop
```

**home-desktop:**
```bash
ssh user@home-desktop
```

### Step 2: Clone or Pull the Flake Repository

```bash
# If first time:
git clone https://github.com/xorpio/nixos-wsl /path/to/nixos-wsl
cd /path/to/nixos-wsl

# If already cloned:
cd /path/to/nixos-wsl
git pull
```

### Step 3: Bootstrap Nix (First-Time Only)

If nix is not installed yet:

**Option A: Determinate Systems Installer (Recommended)**
```bash
curl --proto "=https" --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Option B: Official Nix Installer**
```bash
curl -L https://nixos.org/nix/install | sh
```

After installation, reload your shell:
```bash
exec $SHELL
```

### Step 4: Enable Flake Support

Create or edit `~/.config/nix/nix.conf`:

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### Step 5: Validate the Flake

```bash
cd /path/to/nixos-wsl
nix flake show
```

Expected output includes:
- `nixosConfigurations.daf-laptop`
- `nixosConfigurations.centric-laptop`
- `nixosConfigurations.home-desktop`
- `homeConfigurations.daf@daf-laptop`
- `homeConfigurations.centric@centric-laptop`
- `homeConfigurations.nixos@home-desktop`

### Step 6: Deploy System-Level Configuration

**For NixOS machines (system.nix exists):**

```bash
# daf-laptop:
sudo nixos-rebuild switch --flake /path/to/nixos-wsl#daf-laptop 2>&1 | tee /tmp/daf-rebuild.log

# centric-laptop:
sudo nixos-rebuild switch --flake /path/to/nixos-wsl#centric-laptop 2>&1 | tee /tmp/centric-rebuild.log

# home-desktop:
sudo nixos-rebuild switch --flake /path/to/nixos-wsl#home-desktop 2>&1 | tee /tmp/home-rebuild.log
```

**For non-NixOS machines (use home-manager only):**

If the target is NOT a NixOS system, skip the `nixos-rebuild` step. Instead:

```bash
# Install home-manager if not already installed:
nix run github:nix-community/home-manager -- --version

# daf-laptop (user: daf):
home-manager switch --flake /path/to/nixos-wsl#daf@daf-laptop 2>&1 | tee /tmp/daf-hm.log

# centric-laptop (user: centric):
home-manager switch --flake /path/to/nixos-wsl#centric@centric-laptop 2>&1 | tee /tmp/centric-hm.log

# home-desktop (user: nixos):
home-manager switch --flake /path/to/nixos-wsl#nixos@home-desktop 2>&1 | tee /tmp/home-hm.log
```

### Step 7: Verify Installation

```bash
# Check taskwarrior version (should be 3.x)
task --version

# Check tasksh
tasksh --version

# Check taskwarrior-tui
taskwarrior-tui --help

# Check neovim
nvim --version

# Check vim config (line numbers)
vim +set\ number? +q  # or just: vim, then :set number?

# Log in as the configured user (daf, centric, or nixos) and verify:
zsh --version
git config user.name
```

### Step 8: Troubleshooting

| Issue | Solution |
|-------|----------|
| `sudo: command not found` | You're already root; drop `sudo` prefix |
| `nixos-rebuild: command not found` | Nix is not installed or not in PATH; complete Step 3 |
| `permission denied` writing to nix store | Run as root or add user to `wheel` group: `sudo usermod -aG wheel $USER` |
| `SSL certificate problem` when downloading | Network/certificate issue — try a different nix mirror or check internet connectivity |
| Disk full error | Ensure 2–5 GB free space; run `df -h /` to check |

---

## Deployment Order

**Recommended order (but machines are independent):**

1. **daf-laptop** (primary dev machine) — deploy first
2. **centric-laptop** — deploy second
3. **home-desktop** — deploy third

---

## Post-Deployment

After all three machines are deployed:

1. **Cross-machine consistency check:**
   - Verify all three have the same packages: `task --version`, `nvim --version`, etc.
   - Verify vim config is identical: `vim +set\ number?` on each

2. **Commit any machine-specific changes:**
   - If you made per-machine adjustments, commit to a new branch and create a PR

3. **Optional: Set up git sync:**
   - Configure `git pull` on each machine to keep the flake config in sync with the repository

---

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Central configuration for all three machines |
| `flake.lock` | Locked versions of all dependencies |
| `hosts/daf-laptop/system.nix` | daf-laptop system config |
| `hosts/daf-laptop/home.nix` | daf-laptop home-manager config (packages, vim, git) |
| `hosts/centric-laptop/system.nix` | centric-laptop system config |
| `hosts/centric-laptop/home.nix` | centric-laptop home-manager config |
| `hosts/home-desktop/system.nix` | home-desktop system config |
| `hosts/home-desktop/home.nix` | home-desktop home-manager config |

---

## Configuration Highlights

**All machines include:**
- **Taskwarrior v3** with tasksh and taskwarrior-tui
- **Neovim** with base configuration
- **Vim** with line number enabled (`set number`)
- **Git** per-machine configuration
- **Zsh** shell (if configured)
- **Home-manager** for user-level package management

**No manual post-install tweaks needed** — flake handles everything.

---

## Support

If deployment fails, check:
1. **Build logs:** Read `/tmp/{machine}-rebuild.log` or `/tmp/{machine}-hm.log`
2. **Network:** Verify internet connectivity on the target machine
3. **Nix channel:** Run `nix flake update` to sync lockfile with latest versions
4. **Disk space:** Run `df -h /` and `du -sh /nix` to check store usage
