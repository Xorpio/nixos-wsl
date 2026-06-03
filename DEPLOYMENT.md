# Deployment Guide - Phase 11: Production Rollout

This guide provides instructions for deploying and maintaining the NixOS flake across all three machines in a production-like environment.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Per-Machine Deployment](#per-machine-deployment)
3. [Post-Deployment Operations](#post-deployment-operations)
4. [Updating the Flake](#updating-the-flake)
5. [Managing Secrets](#managing-secrets)
6. [Maintenance Procedures](#maintenance-procedures)
7. [Emergency Procedures](#emergency-procedures)

---

## Quick Start

### First-Time Deployment (All Machines)

For first-time setup, follow these steps on each machine:

#### Prerequisites
```bash
# 1. Verify NixOS is installed
nix --version

# 2. Clone or update repository
git clone https://github.com/yourusername/nixos-wsl.git
cd nixos-wsl

# 3. Set up age key
mkdir -p ~/.config/sops/age
cp /path/to/age/key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

#### Deploy on Each Machine

```bash
# Option 1: Using flake reference (recommended)
home-manager switch --flake '.#user@hostname'

# Option 2: Using local path
home-manager switch --flake '/path/to/nixos-wsl#user@hostname'

# Option 3: With specific generation
home-manager switch --flake '.#user@hostname' -L
```

### Quick Reference: Deployment Commands

| Machine | Command |
|---------|---------|
| **daf-laptop** | `home-manager switch --flake '.#daf@daf-laptop'` |
| **centric-laptop** | `home-manager switch --flake '.#centric@centric-laptop'` |
| **home-desktop** | `home-manager switch --flake '.#nixos@home-desktop'` |

### Verify Deployment

```bash
# Show current generation
home-manager generations | head -1

# Quick functionality check
echo "Shell: $SHELL"
nvim --version
age-keygen -y ~/.config/sops/age/keys.txt
```

---

## Per-Machine Deployment

### daf-laptop Deployment

**Machine Type**: WSL x86_64-linux  
**User**: `daf`  
**Purpose**: Primary development machine

#### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/nixos-wsl.git ~/projects/nixos-wsl
cd ~/projects/nixos-wsl

# 2. Verify flake can be read
nix flake show

# 3. Set up secrets
mkdir -p ~/.config/sops/age
# Copy age key from secure location
# cp /secure/location/daf-laptop.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 4. Test decryption
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d secrets/daf-laptop/secrets.yaml | head -3

# 5. Deploy
home-manager switch --flake '.#daf@daf-laptop'

# 6. Verify
exec $SHELL -l
nvim --version
```

#### Verification Checklist (daf-laptop)
```bash
# Shell works
[ "$SHELL" = "$(which zsh)" ] && echo "✓ Zsh active"

# Aliases available
alias ls | grep -q lsd && echo "✓ Aliases configured"

# Neovim functional
nvim --version | grep -q NVIM && echo "✓ Neovim ready"

# Plugins loaded
[ -d ~/.local/share/nvim/site/pack/packer/start/telescope.nvim ] && echo "✓ Telescope installed"

# Secrets accessible
[ -f ~/.config/sops/age/keys.txt ] && echo "✓ Age key present"

# Git configured
git config --global user.name | grep -q . && echo "✓ Git configured"
```

### centric-laptop Deployment

**Machine Type**: x86_64-linux  
**User**: `centric`  
**Purpose**: Work-focused machine

#### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/nixos-wsl.git ~/work/nixos-wsl
cd ~/work/nixos-wsl

# 2. Set up secrets
mkdir -p ~/.config/sops/age
cp /secure/location/centric-laptop.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 3. Deploy
home-manager switch --flake '.#centric@centric-laptop'

# 4. Verify
exec $SHELL -l
```

#### Verification Checklist (centric-laptop)
```bash
# Machine identity
echo "Hostname: $(hostname)"  # should be: centric-laptop
echo "User: $(whoami)"        # should be: centric

# Work-specific configuration
# (depends on machine-specific home.nix configuration)
```

### home-desktop Deployment

**Machine Type**: x86_64-linux  
**User**: `nixos`  
**Purpose**: Home desktop machine

#### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/nixos-wsl.git ~/nixos-wsl
cd ~/nixos-wsl

# 2. Set up secrets
mkdir -p ~/.config/sops/age
cp /secure/location/home-desktop.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 3. Deploy
home-manager switch --flake '.#nixos@home-desktop'

# 4. Verify
exec $SHELL -l
```

#### Verification Checklist (home-desktop)
```bash
# Machine identity
echo "Hostname: $(hostname)"  # should be: home-desktop
echo "User: $(whoami)"        # should be: nixos

# Desktop-specific features
# (depends on home-desktop configuration)
```

---

## Post-Deployment Operations

### After First Deployment

Immediately after deploying to a machine, perform these checks:

#### 1. Environment Verification (5 minutes)
```bash
# Verify shell is active
exec $SHELL -l

# Check environment variables
env | grep -i XDG

# Test basic commands
ls -la
echo $PATH
which nvim
```

#### 2. Shell Configuration (5 minutes)
```bash
# Test aliases
alias ls

# Test shell functions
# (if any are configured)

# Check command history
history 3
```

#### 3. Neovim Configuration (10 minutes)
```bash
# Launch and check plugins
nvim +'PlugStatus' +'qa!'

# Test key plugins
nvim +'Telescope' +'qa!'  # File finder
nvim +'LspInfo' +'qa!'    # LSP servers

# Check colorscheme
nvim +'colorscheme' +'qa!'
```

#### 4. Secrets Access (5 minutes)
```bash
# Verify sops tool
which sops
sops --version

# Test age key access
age-keygen -y ~/.config/sops/age/keys.txt

# Decrypt sample secret
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops -d secrets/$(hostname)/secrets.yaml | head -5
```

#### 5. Git Integration (5 minutes)
```bash
# Check git config
git config --global user.name
git config --global user.email

# Verify repository connectivity
git remote -v

# Test git operations (on a test branch!)
git branch test-branch
git branch -D test-branch
```

### Updating Machine Configuration

To update configuration on an already-deployed machine:

#### Scenario 1: Pull Latest Changes from Repository

```bash
# 1. Update repository
cd /path/to/nixos-wsl
git pull origin main

# 2. Dry-run to see changes
home-manager switch --flake '.#user@hostname' --dry-run

# 3. Apply changes
home-manager switch --flake '.#user@hostname'

# 4. Verify
exec $SHELL -l
```

#### Scenario 2: Edit Local Machine Configuration

```bash
# 1. Edit machine-specific config
vim hosts/daf-laptop/home.nix

# 2. Dry-run to validate
home-manager switch --flake '.#daf@daf-laptop' --dry-run

# 3. Apply
home-manager switch --flake '.#daf@daf-laptop'

# 4. Test changes
# Verify specific functionality
```

#### Scenario 3: Update Shared Modules

```bash
# 1. Edit shared module
vim modules/shell/default.nix

# 2. Deploy to all machines (one at a time!)
# On daf-laptop:
home-manager switch --flake '.#daf@daf-laptop'

# On centric-laptop:
ssh centric@centric-laptop
cd /path/to/nixos-wsl
home-manager switch --flake '.#centric@centric-laptop'

# On home-desktop:
ssh nixos@home-desktop
cd /path/to/nixos-wsl
home-manager switch --flake '.#nixos@home-desktop'

# 5. Verify on each machine
```

---

## Updating the Flake

### Regular Maintenance Updates

#### Update Input Versions

```bash
# Update all inputs (nixpkgs, home-manager, sops-nix, etc.)
nix flake update

# Or update specific input
nix flake update home-manager

# Or update only nixpkgs
nix flake update nixpkgs
```

#### Review Changes Before Applying

```bash
# See what would change
nix flake update --no-write-lock-file

# Or check diff
git diff flake.lock
```

#### Deploy Updated Flake

```bash
# 1. Test on primary machine first
nix flake update
home-manager switch --flake '.#daf@daf-laptop' --dry-run

# 2. If dry-run looks good, apply
home-manager switch --flake '.#daf@daf-laptop'

# 3. Verify
exec $SHELL -l
nvim --version

# 4. Deploy to other machines
# (on each machine)
git pull origin main
home-manager switch --flake '.#user@hostname'
```

### Adding New Packages

#### Add to Shared Configuration

```bash
# 1. Edit module that should include package
vim modules/shell/default.nix
# or
vim modules/neovim/default.nix

# 2. Add package to configuration
# In Nix: add to packages = [ ... ]

# 3. Test on local machine
nix flake update  # if needed
home-manager switch --flake '.#daf@daf-laptop'

# 4. Verify package installed
which <package-name>

# 5. Commit and deploy to other machines
git add modules/
git commit -m "Add new package to <module>"
# Deploy to other machines (follow deployment steps above)
```

#### Add to Specific Machine

```bash
# 1. Edit machine-specific home.nix
vim hosts/daf-laptop/home.nix

# 2. Add to home.packages
home.packages = with pkgs; [
  # ... existing packages ...
  new-package
];

# 3. Deploy
home-manager switch --flake '.#daf@daf-laptop'

# 4. Verify
which new-package

# 5. Commit
git add hosts/daf-laptop/home.nix
git commit -m "Add new-package to daf-laptop"
```

### Testing New Configurations

#### Dry-Run on Multiple Machines

```bash
# Before committing, test on all machines

# On daf-laptop
home-manager switch --flake '.#daf@daf-laptop' --dry-run

# Check output, then apply if good
home-manager switch --flake '.#daf@daf-laptop'

# Repeat on other machines
```

#### Rollback if Issues Found

```bash
# Revert uncommitted changes
git checkout -- hosts/ modules/

# Or rollback to previous generation
home-manager switch --switch-generation -1

# Verify
exec $SHELL -l
```

---

## Managing Secrets

### Accessing Secrets

#### View Encrypted Secrets

```bash
# Show encrypted file (not human readable)
cat secrets/daf-laptop/secrets.yaml

# View specific secret value
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops -d secrets/daf-laptop/secrets.yaml | grep -A 5 github
```

#### Edit Secrets

```bash
# Edit encrypted secrets (opens in editor)
sops secrets/daf-laptop/secrets.yaml

# Edit specific field
sops -d secrets/daf-laptop/secrets.yaml | grep password
# Then edit via: sops secrets/daf-laptop/secrets.yaml
```

### Adding New Secrets

#### 1. Add to Encrypted File

```bash
# Edit encrypted secrets
sops secrets/daf-laptop/secrets.yaml

# Add new section:
# newapp:
#   api_key: "your-secret-key"
#   token: "your-token"

# Save (automatically re-encrypted)
```

#### 2. Reference in Configuration

```bash
# In home.nix for daf-laptop:
modules.sops = {
  enable = true;
  age.keyFile = ~/.config/sops/age/keys.txt;
  managedSecrets = {
    "newapp_api_key" = {
      sopsFile = ../../secrets/daf-laptop/secrets.yaml;
      key = "newapp.api_key";
      owner = "daf";
      mode = "0400";
    };
  };
};

# Deploy
home-manager switch --flake '.#daf@daf-laptop'
```

#### 3. Use Secret in Shell

```bash
# Secret is available as environment variable
echo $newapp_api_key

# Or from mounted secrets file
cat /run/user/secrets/newapp_api_key
```

### Generating New Age Keys

#### For New Machine

```bash
# Generate age keypair
age-keygen -o secrets/new-machine/.key

# Extract public key
age-keygen -y secrets/new-machine/.key > /tmp/pubkey.txt

# Add public key to .sops.yaml
vim .sops.yaml
# Add under creation_rules:
# - path_regex: secrets/new-machine/.*
#   key_groups:
#   - age: |
#       <paste public key here>

# Test encryption
sops secrets/new-machine/secrets.yaml
# (will prompt to create new file)

# Commit
git add .sops.yaml secrets/new-machine/
git commit -m "Add age key for new-machine"
```

### Backing Up Secrets

#### Safe Backup Procedure

```bash
# 1. Backup encrypted secrets (safe to backup publicly)
cp -r secrets ~/backup/nixos-wsl-secrets-backup

# 2. Backup age keys (MUST be encrypted and stored securely)
# DO NOT commit this anywhere
# Store on encrypted USB or in password manager
gpg --encrypt ~/.config/sops/age/keys.txt
# Copy to secure location: encrypted USB, password manager, etc.

# 3. Document key locations
# In secure location only:
# - daf-laptop age key: <location>
# - centric-laptop age key: <location>
# - home-desktop age key: <location>
```

---

## Maintenance Procedures

### Regular Updates

#### Weekly Maintenance

```bash
# 1. Update system
home-manager switch --flake '.#user@hostname'

# 2. Clean garbage
nix-collect-garbage
nix-collect-garbage -d  # aggressive: removes all old generations

# 3. Update local repository
git fetch origin
git status

# 4. Check for plugin updates (Neovim)
nvim +'PlugUpdate' +'qa!'
```

#### Monthly Maintenance

```bash
# 1. Update all inputs
nix flake update

# 2. Review changes
git diff flake.lock

# 3. Test on primary machine
home-manager switch --flake '.#daf@daf-laptop' --dry-run
home-manager switch --flake '.#daf@daf-laptop'

# 4. Deploy to other machines
# (on each machine)
git pull origin main
home-manager switch --flake '.#user@hostname'

# 5. Clean up
nix-collect-garbage
```

### Monitoring

#### Check Generation Count

```bash
# View all generations
home-manager generations

# Count total generations
home-manager generations | wc -l

# Remove old generations
home-manager remove-generations -d old  # older than 30 days
home-manager remove-generations 10 11 12  # specific generations
```

#### Monitor Disk Usage

```bash
# Check Nix store size
du -sh /nix/store

# See what's taking space
du -sh /nix/store/* | sort -h | tail -20

# Clean unused
nix-collect-garbage -d
```

### Troubleshooting Common Issues

#### "home-manager generation is broken"

```bash
# List generations
home-manager generations

# Identify last working generation
# Switch to it
home-manager switch --switch-generation <number>

# Investigate what broke
git log --oneline -5
git diff HEAD~1 HEAD

# Fix issue
# Edit configuration files to correct issue
home-manager switch --flake '.#user@hostname'
```

#### "Nix store is corrupted"

```bash
# Verify store
nix store verify

# Repair store
nix store repair

# Or regenerate
nix-collect-garbage -d
nix flake update --no-write-lock-file
```

#### "Secrets won't decrypt"

```bash
# Check age key
ls -la ~/.config/sops/age/keys.txt
# Should be: -rw------- 

# Test key
age-keygen -y ~/.config/sops/age/keys.txt

# Check .sops.yaml configuration
cat .sops.yaml | grep -A 5 $(hostname)

# Try decryption with explicit key
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops -d secrets/$(hostname)/secrets.yaml

# If still fails, regenerate key for this machine
# (contact repository maintainer)
```

---

## Emergency Procedures

### Immediate Rollback

If current deployment is broken:

```bash
# Option 1: Rollback to previous generation
home-manager switch --switch-generation -1

# Option 2: Rollback to specific generation
home-manager generations
home-manager switch --switch-generation <stable-generation>

# Option 3: Full reset (last resort)
rm -rf ~/.local/state/home-manager
home-manager switch --flake '.#user@hostname'
```

### Complete Environment Reset

If everything is broken:

```bash
# 1. Backup current state
mkdir -p ~/backup
cp -r ~/.config ~/backup/config-backup-$(date +%s)
cp -r ~/.local ~/backup/local-backup-$(date +%s)

# 2. Full clean reset (WARNING: removes all custom config!)
rm -rf ~/.config
rm -rf ~/.local
mkdir -p ~/.config ~/.local

# 3. Re-deploy from flake
cd /path/to/nixos-wsl
home-manager switch --flake '.#user@hostname'

# 4. Verify everything works
exec $SHELL -l
nvim --version
```

### System Recovery

If Nix itself is broken:

```bash
# 1. Try updating nix
nix-channel --update
nix-env -u

# 2. If that fails, reinstall
# Follow official Nix installation: https://nixos.org/download/

# 3. After reinstall, redeploy flake
cd /path/to/nixos-wsl
home-manager switch --flake '.#user@hostname'
```

---

## Deployment Checklist

Use this checklist when deploying to production:

### Pre-Deployment (30 minutes)
- [ ] All changes committed to main branch
- [ ] Tests passed on daf-laptop
- [ ] Dry-run shows expected changes
- [ ] Secrets are current and accessible
- [ ] Flake updates tested (if applicable)
- [ ] Rollback plan documented

### Deployment (15 minutes per machine)
- [ ] SSH into target machine (or have local access)
- [ ] git pull latest changes
- [ ] Run dry-run: `home-manager switch ... --dry-run`
- [ ] Apply: `home-manager switch ...`
- [ ] Monitor output for errors

### Post-Deployment (15 minutes per machine)
- [ ] Run verification script
- [ ] Test key functionality (shell, neovim, git)
- [ ] Check system logs for errors
- [ ] Document any issues found
- [ ] Confirm generation is current

### Documentation (5 minutes)
- [ ] Update deployment log
- [ ] Note any issues encountered
- [ ] Record deployment time
- [ ] Mark deployment as successful

---

## Support & Resources

### Getting Help

1. **Check logs**: `home-manager switch --flake '.#user@hostname' --verbose`
2. **Review documentation**: See README.md, CONTRIBUTING.md, TESTING.md
3. **Consult flake configuration**: Review your specific `hosts/<hostname>/home.nix`
4. **Search known issues**: Check git log for similar issues

### Additional Resources

- [Home-Manager Manual](https://rycee.gitlab.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [Age Encryption Tool](https://github.com/FiloSottile/age)

---

## Summary

This deployment guide covers:
- Quick start procedures for all three machines
- Per-machine setup and verification
- Post-deployment operations and updates
- Secrets management and rotation
- Regular maintenance procedures
- Emergency rollback and recovery
- Complete checklists for production deployments

For questions or issues, consult the main README.md or TESTING.md guides.
