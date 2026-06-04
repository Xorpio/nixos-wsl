# NixOS WSL Deployment Runbook

**Context:** Multi-machine NixOS WSL config. Three machines. Single flake.  
**Repo (Windows path):** `C:\Users\Niek.de.Gooijer\nixos-wsl`  
**Repo (WSL path):** `/mnt/c/Users/Niek.de.Gooijer/nixos-wsl`  
**Last updated:** 2026-06-04  
**Flake status:** Deployed ✅ (taskwarrior, neovim, vim line numbers committed)

---

## 1. Pre-Deployment Checks

Run these from **inside the target WSL instance** before rebuilding.

### 1a. Bootstrap: Enable Flake Support (first-time only per machine)

If `nix flake show` fails with "nix-command" experimental feature disabled, run once:

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

> After the first successful `nixos-rebuild switch`, this is no longer needed — the system-level nix.conf takes over.

### 1b. Navigate to the Repo

```bash
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl
```

### 1c. Verify Repo Is Clean and Up to Date

```bash
git status
git log --oneline -3
```

Expected: working tree clean, latest commit visible. If dirty, stash or commit first.

### 1d. Validate the Flake (requires flake support from 1a)

```bash
nix flake show /mnt/c/Users/Niek.de.Gooijer/nixos-wsl
```

Expected output includes:
- `nixosConfigurations.daf-laptop`
- `nixosConfigurations.centric-laptop`
- `nixosConfigurations.home-desktop`
- `homeConfigurations.daf@daf-laptop`
- `homeConfigurations.centric@centric-laptop`
- `homeConfigurations.nixos@home-desktop`

### 1e. Check Disk Space

```bash
df -h /
```

Rebuild needs ~2–5 GB free. Abort if under 1 GB free.

### 1f. Confirm Machine Identity

```bash
hostname
whoami
```

| Machine | Expected `hostname` | Expected `whoami` |
|---|---|---|
| daf-laptop | `daf-laptop` | `daf` (or `root` for sudo) |
| centric-laptop | `centric-laptop` | `centric` |
| home-desktop | `home-desktop` | `nixos` |

---

## 2. Deployment Sequence

> Each machine is a separate WSL instance. Run these commands **inside the correct WSL instance** for each machine. Do not cross-deploy.

### Machine 1: daf-laptop

**Open the daf-laptop WSL instance, then:**

```bash
# Navigate to repo
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl

# Bootstrap flake support (first time only — skip if already done)
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Deploy system-level config
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#daf-laptop 2>&1 | tee /tmp/daf-rebuild.log

# Deploy user-level config (home-manager — primary deployment path)
home-manager switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#daf@daf-laptop 2>&1 | tee /tmp/daf-hm.log
```

### Machine 2: centric-laptop

**Open the centric-laptop WSL instance, then:**

```bash
# Navigate to repo
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl

# Bootstrap flake support (first time only — skip if already done)
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Deploy system-level config
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#centric-laptop 2>&1 | tee /tmp/centric-rebuild.log

# Deploy user-level config (home-manager — primary deployment path)
home-manager switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#centric@centric-laptop 2>&1 | tee /tmp/centric-hm.log
```

### Machine 3: home-desktop

**Open the home-desktop WSL instance, then:**

```bash
# Navigate to repo
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl

# Bootstrap flake support (first time only — skip if already done)
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Deploy system-level config
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#home-desktop 2>&1 | tee /tmp/home-rebuild.log

# Deploy user-level config (home-manager — primary deployment path)
home-manager switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#nixos@home-desktop 2>&1 | tee /tmp/home-hm.log
```

> **Note on order:** Deploy daf-laptop first (primary dev machine), then centric-laptop, then home-desktop. Each is independent — a failure on one does not block the others.

---

## 3. Success Criteria

Run these verification commands **on each machine after deployment**.

### 3a. Package Availability (all three machines)

```bash
# Taskwarrior suite
task --version        # Expected: task 3.x.x
tasksh --version      # Expected: tasksh 1.x.x  
taskwarrior-tui       # Expected: launches TUI (exit with q)
nvim --version        # Expected: NVIM v0.9.x or higher
vim --version         # Expected: VIM - Vi IMproved ...

# Confirm packages are from Nix store (not system)
which task nvim vim | head -3
# Expected paths start with /nix/store/... or /home/{user}/.nix-profile/bin/
```

### 3b. Vim Line Numbers

```bash
vim /etc/hostname
```

Expected: line numbers visible in the left margin (`:set number` is active).  
Exit with `:q`.

### 3c. Home-Manager Generation

```bash
home-manager generations | head -3
```

Expected: latest generation shows today's date.

### 3d. Nix Experimental Features Permanent

```bash
cat /etc/nix/nix.conf | grep experimental
```

Expected after nixos-rebuild:
```
experimental-features = nix-command flakes
```

### 3e. Flake Consistency Check (run from any machine)

```bash
nix flake metadata /mnt/c/Users/Niek.de.Gooijer/nixos-wsl | grep -E "Locked|Revision"
```

All three machines should show the same locked revision hash — confirms they are running from the same flake.lock.

---

## 4. Troubleshooting

### Error: `error: experimental Nix feature 'nix-command' is disabled`

**Fix:** Run the bootstrap step from Section 1a:
```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

---

### Error: `error: cannot write to '/etc/nix/nix.conf'` or similar permission errors

**Fix:** nixos-rebuild requires sudo:
```bash
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#daf-laptop
```

---

### Error: `attribute 'daf-laptop' missing` or `flake output 'nixosConfigurations.X' does not exist`

**Cause:** Wrong hostname in the flake target.  
**Fix:** Confirm valid targets:
```bash
nix flake show /mnt/c/Users/Niek.de.Gooijer/nixos-wsl 2>/dev/null | grep nixosConf
```
Use exactly: `daf-laptop`, `centric-laptop`, `home-desktop`.

---

### Error: `error: path '/mnt/c/...' does not exist`

**Cause:** Windows path not accessible from WSL.  
**Fix:** Check WSL mounts:
```bash
ls /mnt/c/Users/Niek.de.Gooijer/nixos-wsl/flake.nix
```
If missing, the Windows drive is not mounted. From WSL:
```bash
sudo mount -t drvfs C: /mnt/c
```
Or restart the WSL instance: `wsl --shutdown` from PowerShell, then reopen.

---

### Error: `home-manager: command not found` (home-manager switch fails)

**Cause:** home-manager not yet on PATH (before first system rebuild).  
**Fix:** Run nixos-rebuild first to install home-manager via the system profile, then retry home-manager switch. Alternatively:
```bash
nix run home-manager/release-24.05 -- switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#daf@daf-laptop
```

---

### Error: `collision between ... taskwarrior ...` or package collision

**Cause:** Package already installed outside Nix profile.  
**Fix:** Check for conflicting installs:
```bash
which task
apt list --installed 2>/dev/null | grep task
```
Remove conflicting system packages, then re-run home-manager switch.

---

### Error: Nix store out of space / `no space left on device`

**Fix:**
```bash
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#HOSTNAME
```

---

### Build hangs / very slow first run

**Expected:** First-ever rebuild fetches all packages from cache (can take 10–30 min on slow connections). Subsequent rebuilds are fast — only changed packages are fetched.  
**Check progress:**
```bash
# In another terminal, watch Nix store activity
watch -n2 'ls /nix/store | wc -l'
```

---

## 5. Rollback Procedure

### Option A: Roll Back to Previous NixOS Generation (system-level)

If nixos-rebuild switch succeeded but the system is broken:

```bash
# List available system generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback

# Or roll back to a specific generation number
sudo nix-env --switch-generation 42 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

### Option B: Roll Back to Previous Home-Manager Generation

If home-manager switch succeeded but your user environment is broken:

```bash
# List home-manager generations
home-manager generations

# Roll back to a previous generation (copy the activation script path from the list)
/nix/store/XXXXX-home-manager-generation/activate
```

### Option C: Git-Based Rollback (config rollback, then redeploy)

If the flake config itself was wrong (e.g., bad module change):

```bash
# From within WSL, navigate to repo
cd /mnt/c/Users/Niek.de.Gooijer/nixos-wsl

# Find the last known-good commit
git log --oneline -10

# Reset to a known-good commit
git checkout <commit-hash> -- flake.nix flake.lock

# Or revert the last commit
git revert HEAD --no-edit

# Redeploy from the reverted config
sudo nixos-rebuild switch --flake /mnt/c/Users/Niek.de.Gooijer/nixos-wsl#HOSTNAME
```

### Option D: Nuclear — WSL Instance Reset

If the WSL instance is completely broken and unbootable:

```powershell
# From Windows PowerShell (NOT WSL)
# Unregister the broken instance (DESTRUCTIVE — data loss)
wsl --unregister daf-laptop  # use the correct distro name

# Reinstall NixOS-WSL from scratch
# Then re-run the full bootstrap from Section 1
```

> ⚠️ Option D destroys all data in the WSL instance. Only use if the instance won't boot at all. The Nix config in `C:\Users\Niek.de.Gooijer\nixos-wsl` survives (it's on Windows filesystem).

---

## Quick Reference

| Machine | Flake target (nixos-rebuild) | Flake target (home-manager) | Default user |
|---|---|---|---|
| daf-laptop | `#daf-laptop` | `#daf@daf-laptop` | `daf` |
| centric-laptop | `#centric-laptop` | `#centric@centric-laptop` | `centric` |
| home-desktop | `#home-desktop` | `#nixos@home-desktop` | `nixos` |

**Repo path (WSL):** `/mnt/c/Users/Niek.de.Gooijer/nixos-wsl`  
**Flake channel:** `nixpkgs-24.05` / `home-manager-release-24.05`  
**Primary deploy command:** `home-manager switch --flake <repo>#<user>@<machine>`  
**System deploy command:** `sudo nixos-rebuild switch --flake <repo>#<machine>`
