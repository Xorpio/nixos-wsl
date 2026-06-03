# NixOS WSL Multi-Machine Configuration - Deployment Guide

## Overview
This repository contains a complete, multi-machine NixOS home-manager configuration managed via a single Nix flake. All three machines (daf-laptop, centric-laptop, home-desktop) are fully configured and ready for deployment.

## Current Status
- ✅ **home-desktop**: Successfully deployed on NixOS WSL
- ✅ **daf-laptop**: Configuration validated
- ✅ **centric-laptop**: Configuration validated

## What's Installed

### All Machines Include:
- **Shell**: Zsh with custom configuration, aliases, and environment variables
- **Git**: Per-machine configuration with name/email
- **Development Tools**:
  - `rg` (ripgrep): Fast recursive grep
  - `fd`: Fast find alternative
  - `bat`: Cat with syntax highlighting
  - `eza`: Modern ls replacement
  - `jq`: JSON query tool
  - `curl`: HTTP client
  - `wget`: File downloader
  - `less`: File pager
  - `man-pages`: Manual documentation

### Secrets Management:
- SOPS configuration ready for encrypted secrets per machine

## How to Deploy

### On WSL (Already Complete)
```bash
# The nixos@home-desktop configuration is already deployed
# Verify it's working:
zsh --version
rg --version
git config user.name
```

### On daf-laptop
SSH or access the daf-laptop machine and run:
```bash
# Clone or pull this repository to the machine
git clone <repo-url> /path/to/config
cd /path/to/config

# Deploy with home-manager
home-manager switch --flake '.#daf@daf-laptop'
```

### On centric-laptop
SSH or access the centric-laptop machine and run:
```bash
# Clone or pull this repository to the machine
git clone <repo-url> /path/to/config
cd /path/to/config

# Deploy with home-manager
home-manager switch --flake '.#centric@centric-laptop'
```

## Directory Structure

```
.
├── flake.nix                 # Main flake configuration
├── flake.lock               # Locked versions of all inputs
├── modules/                 # Shared home-manager modules
│   ├── shell/              # Shell configuration (zsh/bash)
│   ├── git/                # Git configuration
│   ├── dev-tools/          # Development tools
│   ├── sops/               # Secrets management
│   └── neovim/             # Neovim (available but disabled)
├── hosts/                   # Per-machine configurations
│   ├── daf-laptop/home.nix
│   ├── centric-laptop/home.nix
│   └── home-desktop/home.nix
├── .sops.yaml              # SOPS configuration for secrets
└── DEPLOYMENT_GUIDE.md     # This guide
```

## Customization

### Per-Machine Changes
Edit the relevant file in `hosts/*/home.nix`:
- Change aliases, environment variables, tools
- Enable/disable modules
- Add machine-specific configurations

### Shared Module Changes
Edit files in `modules/*/default.nix` to affect all machines

### Applying Changes
After making changes:
```bash
# Test changes (dry-run)
home-manager switch --flake '.#user@machine' --dry-run

# Apply changes
home-manager switch --flake '.#user@machine'

# Or with backup of conflicting files
home-manager switch --flake '.#user@machine' -b backup
```

## Versions
- **nixpkgs**: 24.05 (stable release)
- **home-manager**: release-24.05 (compatible with nixpkgs)
- **sops-nix**: Latest from HEAD

## Troubleshooting

### "USER is set to..." error
Ensure you're running home-manager as the correct user. For deployment on remote machines, SSH as the target user.

### File conflicts during deployment
Use the `-b backup` flag to automatically back up conflicting files:
```bash
home-manager switch --flake '.#user@machine' -b backup
```

### Neovim issues
Neovim is disabled on daf and centric laptops due to WSL build compatibility issues. It can be re-enabled on native NixOS systems by:
1. Uncommenting the neovim import in the machine's home.nix
2. Setting `neovim.enable = true` in the modules section

### Need to refresh flake inputs
```bash
nix flake update
git add flake.lock
git commit -m "Update flake inputs"
```

## Next Steps

1. **On daf-laptop**: SSH and run deployment command above
2. **On centric-laptop**: SSH and run deployment command above
3. **Verify all machines**: Test that shells, git, and tools work on each
4. **Configure secrets**: Set up SOPS keys if needed (see .sops.yaml)

## Support
Refer to:
- [home-manager documentation](https://nix-community.github.io/home-manager/)
- [nix flakes guide](https://nixos.wiki/wiki/Flakes)
- Individual module comments in `modules/*/default.nix`
