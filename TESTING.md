# Testing Guide - Phase 8-10: Flake Deployment & Verification

This guide provides step-by-step instructions for testing the NixOS flake on all three machines. Since direct SSH deployment isn't available in this environment, these instructions document exactly what each machine must execute to deploy and verify the configuration.

## Table of Contents

1. [Pre-Flight Checklist](#pre-flight-checklist)
2. [Phase 8: Flake Verification](#phase-8-flake-verification)
3. [Phase 9: daf-laptop Deployment](#phase-9-daf-laptop-deployment)
4. [Phase 10: Multi-Machine Deployment](#phase-10-multi-machine-deployment)
5. [Verification Procedures](#verification-procedures)
6. [Troubleshooting](#troubleshooting)
7. [Rollback Procedures](#rollback-procedures)

---

## Pre-Flight Checklist

Before attempting deployment on any machine, verify these prerequisites:

### System Requirements
- [ ] Machine has NixOS installed (or WSL with Nix)
- [ ] Machine can access the git repository
- [ ] Machine has internet connectivity (for downloading packages)
- [ ] Sufficient disk space (~2GB for closure)

### Software Requirements
- [ ] Git is installed: `git --version`
- [ ] Nix is installed: `nix --version`
- [ ] Home-manager is available: `home-manager --version` (or will be installed via flake)
- [ ] Age encryption tool available: `age --version`

### Repository Setup
- [ ] Repository cloned locally
- [ ] `.sops.yaml` present in repository root
- [ ] Age key file placed at `~/.config/sops/age/keys.txt`
- [ ] Key file has correct permissions: `chmod 600 ~/.config/sops/age/keys.txt`

### Network Verification
```bash
# Verify git can access repository
git remote -v

# Verify internet connectivity
curl -I https://github.com
```

---

## Phase 8: Flake Verification (Task 8.1)

### Task 8.1: Verify Flake Evaluation

Before deploying to any machine, verify the flake structure is correct.

#### Step 1: Check Flake Syntax
```bash
# Navigate to repository root
cd /path/to/nixos-wsl

# Check flake syntax and structure
nix flake show

# Expected output:
# path: /path/to/nixos-wsl
# ├─ devShells
# │  └─ x86_64-linux
# │     └─ default: 'shell'
# └─ nixosConfigurations
#    ├─ centric-laptop: 'nixosConfiguration'
#    ├─ daf-laptop: 'nixosConfiguration'
#    └─ home-desktop: 'nixosConfiguration'
```

#### Step 2: Verify Flake Lock File
```bash
# Check that flake.lock was created
ls -lh flake.lock

# Expected: file should exist and be relatively recent
# This tracks all input versions for reproducibility
```

#### Step 3: Evaluate for daf-laptop
```bash
# Test that the flake evaluates correctly for daf-laptop
nix build --dry-run '.#nixosConfigurations.daf-laptop.config.system.build.toplevel'

# Should complete without errors
# Errors here indicate configuration problems that must be fixed before proceeding
```

#### Step 4: Check Home-Manager Output
```bash
# Verify home-manager configuration is included
nix eval '.#nixosConfigurations.daf-laptop' --apply 'x: x.config.home-manager.users.daf'

# Should output attribute set with home-manager configuration
```

#### Troubleshooting Flake Issues
If flake evaluation fails:

```bash
# Get more detailed error information
nix flake check --allow-import-from-derivation 2>&1 | head -50

# Check for Nix syntax errors
nix eval ./flake.nix 2>&1

# Validate individual modules
nix eval '.#nixosConfigurations.daf-laptop.config.home.packages'
```

---

## Phase 9: daf-laptop Deployment

### Prerequisites for daf-laptop
- [ ] Machine is a WSL instance or x86_64-linux NixOS system
- [ ] Username on machine is `daf`
- [ ] Hostname on machine is `daf-laptop`
- [ ] Age key is placed at `~/.config/sops/age/keys.txt`

### Task 9.1: Dry-Run Home-Manager Configuration

Before applying changes, perform a dry-run to see what would be deployed:

```bash
# From repository root
home-manager switch --flake '.#daf@daf-laptop' --dry-run

# Output shows:
# - Packages to be installed
# - Configuration files to be created
# - Shell configurations
# - Neovim plugins to be linked
# - Secrets to be decrypted and placed
```

#### Dry-Run Success Indicators
- [ ] No error messages (only warnings are acceptable)
- [ ] List of packages to be installed
- [ ] Configuration files shown
- [ ] Shell initialization files listed
- [ ] Can scroll through without crashes

#### Dry-Run Issues
```bash
# If dry-run fails, check specific issues:

# Check home-manager can find the flake output
home-manager flake '.#daf@daf-laptop' --debug 2>&1 | grep -i error

# Verify modules can load
nix eval '.#nixosConfigurations.daf-laptop.config.home-manager.users.daf' --debug 2>&1 | tail -50

# Check for attribute missing errors
home-manager switch --flake '.#daf@daf-laptop' --show-trace 2>&1 | head -30
```

### Task 9.2: Apply Home-Manager Configuration

After successful dry-run, apply the configuration:

```bash
# Apply home-manager configuration
home-manager switch --flake '.#daf@daf-laptop'

# Monitor output for:
# - Package installation progress
# - File creation confirmations
# - Any permission/permission-denied errors
# - Activation script completion
```

#### Application Success Indicators
- [ ] Process completes without errors
- [ ] Home-manager reports "done" or similar
- [ ] Can run subsequent commands
- [ ] Shell still responsive

#### If Application Fails
```bash
# View detailed error information
home-manager switch --flake '.#daf@daf-laptop' --show-trace 2>&1 | tail -100

# Check what changed
home-manager switch --flake '.#daf@daf-laptop' --verbose 2>&1 | tail -50

# Review activation script
home-manager switch --flake '.#daf@daf-laptop' --validate 2>&1
```

### Task 9.3: Verify Shell Configuration

After deployment, verify the shell is correctly configured:

```bash
# Restart shell or source configuration
exec $SHELL -l

# Test shell works
echo "Shell test"
# Expected: "Shell test" (no errors)

# Check shell type
echo $SHELL
# Expected: should be /run/current-system/sw/bin/zsh or /run/current-system/sw/bin/bash

# Check aliases are available
alias ls
# Expected: should show custom ls alias
```

#### Shell Configuration Verification Checklist
```bash
# 1. Check ZSH is configured (if enabled)
which zsh
zsh --version

# 2. Verify aliases work
ls -l ~
# (should use configured alias settings)

# 3. Test environment variables
echo $XDG_CONFIG_HOME
# Expected: ~/.config or similar

# 4. Check history works
history 1
# Should show recent commands
```

### Task 9.4: Verify Neovim Configuration

After shell configuration, verify Neovim:

```bash
# Check neovim is installed
nvim --version
# Expected: NVIM v0.9.0 or later

# Launch neovim and check plugins load
nvim +PlugStatus +qall

# Check plugins in detail
nvim -c 'call execute("set number")' -c 'PlugStatus' -c 'qa!'
```

#### Neovim Verification Checklist
```bash
# 1. Check plugin directory
ls -la ~/.local/share/nvim/site/pack/packer/start/
# Should list all installed plugins

# 2. Verify key plugins exist
for plugin in telescope nvim-lspconfig nvim-treesitter gruvbox-nvim; do
  if [ -d "$HOME/.local/share/nvim/site/pack/packer/start/$plugin" ]; then
    echo "✓ $plugin"
  else
    echo "✗ $plugin MISSING"
  fi
done

# 3. Test Telescope works
nvim +Telescope +qall
# Should open Telescope finder

# 4. Check LSP configuration
nvim +"LspInfo" +qall
# Should list configured LSP servers

# 5. Verify colorscheme
nvim +'set background=dark' +'colorscheme gruvbox' +qall
# Should apply gruvbox colorscheme without errors
```

---

## Phase 10: Multi-Machine Deployment

### Deployment Order

Deploy machines in this order to catch issues early:

1. **daf-laptop** (primary development machine) ← Phase 9 (already done)
2. **centric-laptop** (work machine) ← Phase 10.1-10.2
3. **home-desktop** (home machine) ← Phase 10.3-10.4

Each machine's deployment follows the same pattern: dry-run → apply → verify.

### Phase 10.1-10.2: centric-laptop Deployment

#### Prerequisites
- [ ] Machine hostname is `centric-laptop`
- [ ] Username on machine is `centric`
- [ ] Age key at `~/.config/sops/age/keys.txt`

#### Deployment Steps

```bash
# Step 1: Dry-run
home-manager switch --flake '.#centric@centric-laptop' --dry-run
# Review output - should show packages and configuration

# Step 2: Apply
home-manager switch --flake '.#centric@centric-laptop'
# Monitor for successful completion

# Step 3: Verify shell (same as Phase 9.3)
exec $SHELL -l
echo "Shell working"

# Step 4: Verify neovim (same as Phase 9.4)
nvim --version
```

#### Post-Deployment Verification for centric-laptop
```bash
# Verify machine-specific configuration
echo "Machine: $(hostname)"
# Expected: centric-laptop

echo "User: $(whoami)"
# Expected: centric

# Check work-specific aliases (if configured)
alias | grep -i work
# Expected: work-related aliases if configured in machine config
```

### Phase 10.3-10.4: home-desktop Deployment

#### Prerequisites
- [ ] Machine hostname is `home-desktop`
- [ ] Username on machine is `nixos`
- [ ] Age key at `~/.config/sops/age/keys.txt`

#### Deployment Steps

```bash
# Step 1: Dry-run
home-manager switch --flake '.#nixos@home-desktop' --dry-run
# Review output - should show packages and configuration

# Step 2: Apply
home-manager switch --flake '.#nixos@home-desktop'
# Monitor for successful completion

# Step 3: Verify shell
exec $SHELL -l
echo "Shell working"

# Step 4: Verify neovim
nvim --version
```

#### Post-Deployment Verification for home-desktop
```bash
# Verify machine identity
echo "Machine: $(hostname)"
# Expected: home-desktop

echo "User: $(whoami)"
# Expected: nixos

# Check home-specific configuration
alias | head -10
# Expected: should show custom aliases
```

---

## Verification Procedures

After deploying to any machine, run these comprehensive verification procedures:

### Complete Verification Suite

Run this script on each deployed machine:

```bash
#!/bin/bash
set -e

echo "=== NixOS Flake Deployment Verification ==="
echo

# 1. System Information
echo "1. System Information"
echo "   Hostname: $(hostname)"
echo "   User: $(whoami)"
echo "   OS: $(uname -s)"
echo "   Kernel: $(uname -r)"
echo

# 2. Nix Environment
echo "2. Nix Configuration"
echo "   Nix version: $(nix --version)"
nix eval --version
echo

# 3. Home-Manager
echo "3. Home-Manager"
echo "   Location: $(which home-manager)"
home-manager --version
echo

# 4. Shell Configuration
echo "4. Shell Configuration"
echo "   Shell: $SHELL"
echo "   Shell version: $($SHELL --version 2>&1 | head -1)"
echo "   XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set}"
echo

# 5. Aliases
echo "5. Key Aliases"
alias | grep -E '^alias (ls|grep|grep|cd)=' || echo "   Standard aliases present"
echo

# 6. Neovim
echo "6. Neovim"
nvim --version | head -3
echo "   Plugin directory: $(ls ~/.local/share/nvim/site/pack/packer/start/ 2>/dev/null | wc -l) plugins"
echo

# 7. Sops/Age
echo "7. Secrets Management"
echo "   Sops: $(which sops 2>/dev/null || echo 'NOT INSTALLED')"
echo "   Age: $(which age 2>/dev/null || echo 'NOT INSTALLED')"
if [ -f ~/.config/sops/age/keys.txt ]; then
    echo "   Age key: PRESENT"
    age-keygen -y ~/.config/sops/age/keys.txt > /tmp/pubkey.txt 2>&1
    echo "   Public key works: YES"
    rm -f /tmp/pubkey.txt
else
    echo "   Age key: MISSING"
fi
echo

# 8. Git Integration
echo "8. Git Integration"
git version
if [ -d .git ]; then
    echo "   Current repo: $(git remote get-url origin | tail -1)"
fi
echo

echo "=== Verification Complete ==="
```

Save this as `verify-deployment.sh` and run:
```bash
bash verify-deployment.sh
```

### Per-Component Verification

#### Verify Shell Configuration
```bash
# Test shell initialization
exec $SHELL -l

# Check environment variables are set
env | grep -i XDG

# Test aliases work
ls -la ~  # should use alias settings

# Check history
history 5
```

#### Verify Neovim Installation
```bash
# Check neovim runs
nvim --version

# Check plugins installed
ls -l ~/.local/share/nvim/site/pack/packer/start/ | head -20

# Test key plugins
nvim +'call feedkeys(":\<C-C>")' +'Telescope' +'qa!'  # Should open without error

# Check LSP config
nvim +'LspInfo' +'qa!'  # Should show LSP servers
```

#### Verify Secrets Decryption
```bash
# Check sops is available
which sops
sops --version

# Check age keys are in place
ls -la ~/.config/sops/age/keys.txt
# Should show: -rw------- (600 permissions)

# Test decryption
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d secrets/$(hostname)/secrets.yaml | head -5
# Should show decrypted YAML without errors
```

#### Verify Git Configuration
```bash
# Check git config
git config --global user.name
git config --global user.email

# Test git works
git status

# Check SSH if configured
ssh -T git@github.com 2>&1 | head -5
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "home-manager: command not found"

**Cause**: Home-manager not installed or not in PATH

**Solution**:
```bash
# Option 1: Use full path
~/.nix-profile/bin/home-manager switch --flake '.#daf@daf-laptop'

# Option 2: Add to PATH
export PATH="~/.nix-profile/bin:$PATH"
home-manager switch --flake '.#daf@daf-laptop'

# Option 3: Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
nix-env -iA nixpkgs.home-manager
```

#### Issue: "flake output missing" or "Attribute not found"

**Cause**: Incorrect flake reference format or missing configuration

**Solution**:
```bash
# Verify flake outputs exist
nix flake show

# Check correct format: user@hostname
# Should be: daf@daf-laptop (not daf-laptop@daf)

# Verify configuration file exists
ls -la hosts/daf-laptop/home.nix

# Test evaluation
nix eval '.#nixosConfigurations.daf-laptop'
```

#### Issue: "Age key not found" or "Sops decryption failed"

**Cause**: Missing or incorrectly placed age key

**Solution**:
```bash
# Create sops directory
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age

# Verify key placement
ls -la ~/.config/sops/age/keys.txt
# Should show: -rw------- user user

# Test with explicit key
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d secrets/daf-laptop/secrets.yaml

# If still fails, check key is valid
age-keygen -y ~/.config/sops/age/keys.txt
```

#### Issue: "Package not found" or download failures

**Cause**: Network issues or cache problems

**Solution**:
```bash
# Clear nix cache
nix-collect-garbage

# Try again with verbose output
home-manager switch --flake '.#daf@daf-laptop' --verbose

# Check network
ping archive.nixos.org
curl -I https://cache.nixos.org/

# Use fallback cache
export NIX_BUILD_CORES=1
export NIX_BINARY_CACHES="https://cache.nixos.org https://cache.garnix.io"
```

#### Issue: "neovim plugins not loading" or "LSP not working"

**Cause**: Plugin installation incomplete or missing dependencies

**Solution**:
```bash
# Restart neovim
nvim +'call execute("set packpath?")' +'qa!'

# Check plugin path
ls -la ~/.local/share/nvim/site/pack/packer/start/

# Verify treesitter parsers
nvim +'TSCheckHealth' +'qa!'

# Check LSP configuration
nvim +'LspInfo' +'qa!'

# Start fresh (backup first!)
cp -r ~/.local/share/nvim ~/.local/share/nvim.bak
rm -rf ~/.local/share/nvim
# Re-apply home-manager
home-manager switch --flake '.#daf@daf-laptop'
```

#### Issue: "Shell not sourcing configuration" or "Aliases not working"

**Cause**: Shell not reloading configuration or path issues

**Solution**:
```bash
# Force shell reload
exec $SHELL -l

# Check shell RC file
echo $SHELL
cat ~/.zshrc | head -20  # or ~/.bashrc

# Verify home-manager managed files
ls -la ~/.config/

# Source manually
source ~/.zshrc  # or ~/.bashrc

# Check for syntax errors
zsh -n ~/.zshrc  # or bash for bashrc
```

### Debug Mode Deployment

For persistent issues, deploy with maximum verbosity:

```bash
# Full trace on error
home-manager switch --flake '.#daf@daf-laptop' --show-trace 2>&1 | tee deployment.log

# With NIX debug
nix-build --show-trace --keep-going '.#nixosConfigurations.daf-laptop' 2>&1 | tee build.log

# Check activation script
home-manager switch --flake '.#daf@daf-laptop' --verbose 2>&1 | grep -i activation

# Review logs
cat ~/.local/state/home-manager/activation-$(date +%s).log  # or similar
```

---

## Rollback Procedures

If deployment causes issues, rollback to previous configuration:

### Rollback Steps

#### Step 1: Check Available Generations
```bash
# List all home-manager generations
home-manager generations

# Output example:
# 2024-03-06 21:00:00 -> /nix/store/...-home-manager-generation-N
# 2024-03-06 20:30:00 -> /nix/store/...-home-manager-generation-N-1
```

#### Step 2: Identify Problem Generation
```bash
# Note the generation number of the working configuration
# Usually the second one in the list (previous generation)
```

#### Step 3: Rollback
```bash
# Rollback to previous generation
home-manager switch --switch-generation <generation-number>

# For example, to go back 1 generation:
home-manager switch --switch-generation $(( $(home-manager --version | cut -d' ' -f1) - 1 ))

# Or use relative time:
home-manager switch --switch-generation -1  # go back 1 generation
```

#### Step 4: Verify Rollback
```bash
# Check you're on the previous generation
home-manager generations | head -1

# Verify previous configuration works
exec $SHELL -l
echo "Shell working after rollback"
```

### Complete Rollback Example

If deployment on daf-laptop fails:

```bash
# Show available generations
home-manager generations

# Rollback to previous (usually index 1, or -1)
home-manager switch --switch-generation -1

# Verify
exec $SHELL -l
nvim --version
```

### Prevention: Keep Generations

```bash
# Keep more generations for easier recovery
# Add to home.nix:
home.stateVersion = "24.05";
news.display = "silent";

# Or set globally
home-manager --keep-generations 5 switch --flake '.#daf@daf-laptop'
```

---

## Success Criteria

All deployments are successful when:

- [ ] Dry-run completes without errors
- [ ] Application completes successfully
- [ ] Shell works and aliases are available
- [ ] Neovim launches and plugins load
- [ ] No errors in verification script
- [ ] Age keys are in place and functional
- [ ] Previous generation available for rollback

---

## Next Steps

After successful verification on all three machines:

1. Run final validation checklist (see VALIDATION-CHECKLIST.md)
2. Document any machine-specific findings
3. Create deployment record commit
4. Archive testing documentation
5. Begin Phase 11: Final documentation updates

See DEPLOYMENT.md for post-deployment operations and CONTRIBUTING.md for maintaining the flake.
