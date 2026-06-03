# NixOS Flake Configuration - Multi-Machine Setup

A comprehensive Nix flake for managing three Linux machines (daf-laptop, centric-laptop, home-desktop) with shared home-manager configurations, sops-nix secrets management, and customizable Neovim setup.

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/yourusername/nixos-wsl.git
cd nixos-wsl

# 2. Set up secrets
mkdir -p ~/.config/sops/age
cp /path/to/age/key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 3. Deploy configuration
home-manager switch --flake '.#USER@HOSTNAME'

# 4. Verify
exec $SHELL -l && nvim --version
```

See [Complete Setup Instructions](#setup-instructions) below.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Machines](#machines)
4. [Key Features](#key-features)
5. [Setup Instructions](#setup-instructions)
6. [Deployment](#deployment)
7. [Guides & Documentation](#guides--documentation)
8. [Development](#development)

---

## 📖 Overview

This repository contains a unified Nix/Home-Manager configuration for managing **three Linux machines**:

- **daf-laptop**: WSL x86_64-linux - Primary development (user: `daf`)
- **centric-laptop**: x86_64-linux - Work machine (user: `centric`)
- **home-desktop**: x86_64-linux - Home machine (user: `nixos`)

### ✨ Key Principles

✅ **Single Source of Truth** - One flake manages all three machines  
✅ **Code Reuse** - Shared modules with per-machine customization  
✅ **Reproducibility** - Locked inputs ensure identical environments  
✅ **Secrets Management** - sops-nix with age encryption  
✅ **Easy Rollback** - All generations preserved  
✅ **Well Documented** - Complete guides for all operations  

---

## 🏗️ Architecture

### File Structure

```
nixos-wsl/
├── flake.nix                      # Main entry point
├── flake.lock                     # Locked input versions
├── hosts/                         # Per-machine configurations
│   ├── daf-laptop/home.nix
│   ├── centric-laptop/home.nix
│   └── home-desktop/home.nix
├── modules/                       # Shared reusable modules
│   ├── shell/default.nix          # Zsh/Bash config
│   ├── neovim/default.nix         # Editor (26+ plugins)
│   ├── git/default.nix            # Git config
│   ├── sops/default.nix           # Secrets management
│   └── [other modules]/
├── nvim-config/                   # Neovim Lua config
├── secrets/                       # Encrypted secrets
│   ├── .sops.yaml                 # Sops config (committed)
│   ├── daf-laptop/secrets.yaml    # Encrypted secrets
│   ├── centric-laptop/secrets.yaml
│   └── home-desktop/secrets.yaml
└── [documentation files]
```

### Configuration Flow

```
flake.nix (entry point)
  ↓ Evaluates for target machine
  ↓
hosts/{hostname}/home.nix
  ↓ Imports shared modules
  ↓
modules/{shell,neovim,git,sops,...}
  ↓ Merges with per-machine config
  ↓
Home-Manager applies configuration
  ↓ Decrypts secrets (if enabled)
  ↓
User environment ready
```

---

## 🖥️ Machines

| Machine | System | User | Purpose | Deploy |
|---------|--------|------|---------|--------|
| **daf-laptop** | WSL x86_64 | `daf` | Development | `home-manager switch --flake '.#daf@daf-laptop'` |
| **centric-laptop** | x86_64 | `centric` | Work | `home-manager switch --flake '.#centric@centric-laptop'` |
| **home-desktop** | x86_64 | `nixos` | Home | `home-manager switch --flake '.#nixos@home-desktop'` |

---

## ⭐ Key Features

### 1. Shared Modules

Five reusable modules for composable configuration:

| Module | Purpose | Customizable |
|--------|---------|--------------|
| **shell** | Zsh/Bash with aliases | Per-machine |
| **neovim** | Editor with 26+ plugins | Per-machine |
| **git** | Git configuration | Per-machine |
| **direnv** | Dev environments | Per-machine |
| **sops** | Encrypted secrets | Per-machine |

### 2. Neovim (26+ plugins)

- **Navigation**: Telescope, which-key
- **Syntax**: Treesitter
- **LSP**: nvim-lspconfig, cmp
- **UI**: Lualine, gruvbox, indent-blankline
- **Git**: Fugitive, gitsigns
- **Editing**: Surround, commentary, repeat

**Key bindings**:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>e` - File explorer
- `[d`/`]d` - Diagnostics

### 3. Secrets Management

- **sops-nix** for encryption
- **age** for per-machine keys
- **Automatic decryption** on login
- **Easy rotation** via sops CLI

### 4. Shell Configuration

- **Zsh** or **Bash**
- Pre-configured aliases
- Environment variables
- Per-machine customization

### 5. Git Integration

- Global user config
- SSH/HTTPS support
- Per-machine credentials
- Custom aliases

### 6. Pre-Commit Hooks

Automatic code quality checks:
- Line ending enforcement
- Trailing whitespace removal
- JSON/YAML validation
- Shell script linting
- Secret detection

---

## 🔧 Setup Instructions

### Prerequisites

```bash
# Verify Nix installed
nix --version              # Should be 2.16.0+

# Verify Git installed
git --version              # Should be 2.30+

# Verify age available
age --version              # If missing: nix profile install nixpkgs#age
```

### First-Time Setup

#### Step 1: Clone Repository
```bash
git clone https://github.com/yourusername/nixos-wsl.git
cd nixos-wsl
nix flake show
```

#### Step 2: Set Up Secrets
```bash
# Create sops directory
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age

# Place age key for your machine
cp /secure/location/age-key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Verify key works
age-keygen -y ~/.config/sops/age/keys.txt
```

#### Step 3: Dry-Run
```bash
# See what would be deployed
home-manager switch --flake '.#USER@HOSTNAME' --dry-run

# Scroll through output and verify changes look correct
```

#### Step 4: Deploy
```bash
# Apply configuration
home-manager switch --flake '.#USER@HOSTNAME'

# Reload shell
exec $SHELL -l
```

#### Step 5: Verify
```bash
# Run verification script
bash secrets/verify-sops.sh

# Manual checks
echo "Shell: $SHELL"
nvim --version | head -1
which age
alias ls
```

### Updating Configuration

```bash
# Pull latest changes
cd nixos-wsl
git pull origin main

# Deploy updates
home-manager switch --flake '.#USER@HOSTNAME'

# Reload shell
exec $SHELL -l
```

### Adding New Packages

```bash
# Edit configuration
vim modules/shell/default.nix          # For all machines
# or
vim hosts/daf-laptop/home.nix          # For one machine

# Add to home.packages
home.packages = with pkgs; [
  existing-package
  new-package-name
];

# Deploy
home-manager switch --flake '.#USER@HOSTNAME'
```

---

## 🚀 Deployment

### Deployment Command Reference

```bash
# Primary machine (daf-laptop)
home-manager switch --flake '.#daf@daf-laptop'

# Work machine (centric-laptop)
home-manager switch --flake '.#centric@centric-laptop'

# Home machine (home-desktop)
home-manager switch --flake '.#nixos@home-desktop'

# With dry-run (safe to test)
home-manager switch --flake '.#USER@HOSTNAME' --dry-run
```

### Multi-Machine Deployment

Deploy to all machines (one at a time for safety):

```bash
# 1. SSH into each machine

# 2. Update repository
git pull origin main

# 3. Deploy
home-manager switch --flake '.#USER@HOSTNAME'

# 4. Verify
exec $SHELL -l
nvim --version
```

### Rollback

```bash
# View generations
home-manager generations

# Rollback to previous
home-manager switch --switch-generation -1

# Or to specific generation
home-manager switch --switch-generation N
```

For detailed deployment instructions, see **[DEPLOYMENT.md](DEPLOYMENT.md)**

---

## 📚 Guides & Documentation

### Complete Documentation

| Guide | Purpose | Read When |
|-------|---------|-----------|
| **[TESTING.md](TESTING.md)** | Complete testing procedures | Before first deployment |
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | Deployment & maintenance | Setting up or updating machines |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Development guidelines | Contributing changes |
| **[VALIDATION-CHECKLIST.md](VALIDATION-CHECKLIST.md)** | Final validation | After all deployments |
| **[secrets/README.md](secrets/README.md)** | Secrets management | Working with encrypted data |
| **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** | Command cheat sheet | Quick lookups |

### Pre-Commit Hooks

This repository enforces code quality with pre-commit hooks:

```bash
# Install hooks (one-time)
pre-commit install

# Hooks run automatically on commit
git commit -m "Your message"

# Manual check
pre-commit run --all-files
```

---

## 👨‍💻 Development

### Add New Shared Module

```bash
# Create module directory
mkdir -p modules/mymodule

# Create default.nix with module definition
cat > modules/mymodule/default.nix << 'EOF'
{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.mymodule = {
    enable = mkEnableOption "mymodule";
  };

  config = mkIf config.modules.mymodule.enable {
    # Your configuration here
  };
}
EOF

# Import in hosts/*/home.nix
# Then use: modules.mymodule.enable = true;
```

### Create New Machine Configuration

```bash
# 1. Create directory
mkdir -p hosts/new-machine

# 2. Create home.nix
cat > hosts/new-machine/home.nix << 'EOF'
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../../modules/shell
    ../../modules/neovim
    ../../modules/git
  ];

  modules.shell.enable = true;
  modules.neovim.enable = true;
  
  home.username = "newuser";
  home.homeDirectory = "/home/newuser";
}
EOF

# 3. Generate age key
mkdir -p secrets/new-machine
age-keygen -o secrets/new-machine/.key

# 4. Add public key to .sops.yaml

# 5. Create secrets file
sops secrets/new-machine/secrets.yaml
```

### Troubleshooting

#### "command not found: home-manager"
```bash
export PATH="~/.nix-profile/bin:$PATH"
home-manager --version
```

#### "Flake output not found"
```bash
nix flake show              # Check outputs exist
ls hosts/daf-laptop/home.nix  # Check config file exists
```

#### "Secrets won't decrypt"
```bash
ls -la ~/.config/sops/age/keys.txt  # Should be -rw------- 
age-keygen -y ~/.config/sops/age/keys.txt  # Test key
```

For more troubleshooting, see **[TESTING.md](TESTING.md)**

---

## 🛠️ Common Tasks

### View installed plugins (Neovim)
```bash
nvim +'PlugStatus' +'qa!'
# or check directory
ls ~/.local/share/nvim/site/pack/packer/start/
```

### Test Telescope (file finder)
```bash
nvim +'Telescope' +'qa!'
```

### Edit encrypted secrets
```bash
sops secrets/daf-laptop/secrets.yaml
# Edit, save - automatically re-encrypted
```

### View Git configuration
```bash
git config --global --list
```

### Check shell aliases
```bash
alias ls
alias grep
```

### Update inputs (nixpkgs, home-manager)
```bash
nix flake update
# Review changes
git diff flake.lock
```

---

## 📦 What's Included

### Languages & Tools (if configured)
- Node.js, Python, Go, Rust
- Prettier, Black, Gofmt
- ESLint, Pylint, Shellcheck
- Git, SSH, Age encryption

### Shells
- Zsh (default)
- Bash (fallback)

### Editors
- Neovim (fully configured)
- With 26+ plugins

### Development
- Home-manager integration
- Flakes support
- Sops-nix secrets
- Pre-commit hooks

---

## 📋 Local Development Setup

This repository uses pre-commit hooks to enforce code quality standards.

### Setup

```bash
# Install pre-commit framework
pip install --user pre-commit

# Install hooks
pre-commit install

# Hooks now run automatically on git commit
```

### What Hooks Check

- ✅ Line endings (LF only)
- ✅ Trailing whitespace
- ✅ File formatting
- ✅ JSON/YAML validation
- ✅ Shell script linting
- ✅ Secret detection
- ✅ File size limits

### Configuration

- `.editorconfig` - Editor settings
- `.gitattributes` - Git attributes
- `.gitignore` - Ignore patterns
- `.pre-commit-config.yaml` - Hook config

---

## 🔐 Security

### Secrets Management

✅ **Encrypted** with sops-nix + age  
✅ **Per-machine** key isolation  
✅ **Automatic decryption** on login  
✅ **Never committed**: Private keys stay local  
✅ **Committed**: Public keys, encrypted values, configs  

### What's Protected

```
secrets/
├── .sops.yaml          ← Committed (public keys only)
├── daf-laptop/
│   ├── .key            ← NOT COMMITTED (private!)
│   └── secrets.yaml    ← Committed (encrypted)
├── centric-laptop/
│   ├── .key            ← NOT COMMITTED (private!)
│   └── secrets.yaml    ← Committed (encrypted)
└── home-desktop/
    ├── .key            ← NOT COMMITTED (private!)
    └── secrets.yaml    ← Committed (encrypted)
```

---

## 📖 Resources

- [Home-Manager Manual](https://rycee.gitlab.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Sops-nix](https://github.com/Mic92/sops-nix)
- [Age Encryption](https://github.com/FiloSottile/age)

---

## ✅ Checklist: All Set?

- [ ] Nix 2.16.0+ installed
- [ ] Git configured
- [ ] Age tool available
- [ ] Repository cloned
- [ ] Age keys placed in `~/.config/sops/age/keys.txt`
- [ ] Dry-run successful
- [ ] Configuration deployed
- [ ] Shell reloaded
- [ ] Verification script passed

---

## 🎉 Summary

This flake provides everything needed to:
- ✅ Manage three machines from one configuration
- ✅ Share common setup via reusable modules
- ✅ Decrypt secrets automatically
- ✅ Deploy atomic updates with home-manager
- ✅ Rollback to previous generations
- ✅ Maintain code quality with pre-commit
- ✅ Ensure reproducibility via lock files

**Get started**: Clone, set up secrets, run `home-manager switch --flake '.#USER@HOSTNAME'`

---

## 📞 Support

Questions? Check:
1. [TESTING.md](TESTING.md) - Troubleshooting guide
2. [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment procedures
3. [secrets/README.md](secrets/README.md) - Secrets setup
4. Git log for similar issues

**Happy Nix-ing! 🚀**
