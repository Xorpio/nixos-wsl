# Copilot Instructions for nixos-wsl

## Overview

This repository contains multiple NixOS WSL configurations using **Flakes** and **Home Manager**, each tailored to a specific machine. Both prioritize simplicity and maintainability.

### Available Configurations

- **`daf-laptop`**: Corporate machine with PACCAR certificate requirements
- **`desktop-pc`**: Personal machine (no corporate dependencies)

Both split system and home settings into separate files:
- `hosts/{machine}/default.nix` — NixOS system config
- `hosts/{machine}/home.nix` — Home Manager user config

## Build & Rebuild Commands

To rebuild any machine, use its flake name:

```bash
# For daf-laptop (corporate)
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop

# For desktop-pc (clean)
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc
```

Shell aliases are defined in each machine's `home.nix`:
```bash
rebuild  # Alias for that machine's rebuild command
hm       # Same as rebuild (HM is system-integrated)
```

## Architecture

### Flake Structure

`flake.nix` defines four output configurations:
- `nixosConfigurations.daf-laptop` — Full system (NixOS + Home Manager)
- `homeConfigurations."daf@daf-laptop"` — Home Manager standalone
- `nixosConfigurations.desktop-pc` — Full system (NixOS + Home Manager)
- `homeConfigurations."daf@desktop-pc"` — Home Manager standalone

### Key Dependencies
- **nixos-wsl**: Provides WSL-specific module (`nixos-wsl.nixosModules.wsl`)
- **home-manager**: User environment management (pinned to `release-25.05`)
- **nixpkgs**: `nixos-25.05` channel

All inputs follow `nixpkgs` for consistency.

### Home Manager Integration

Home Manager is configured at the system level (`home-manager.useGlobalPkgs = true; home-manager.useUserPackages = true`) on both machines:
- Home Manager runs as part of system rebuild
- No separate `home-manager` CLI tool needed
- Faster rebuilds due to Nix caching

## Machine-Specific Details

### daf-laptop (Corporate)

**Prerequisites:**
- `/etc/nixos/paccar-root.crt` must exist on the host before the first rebuild
- Required for all network operations (git, curl, nix flake updates)

**Special config in `default.nix`:**
```nix
security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];
```

### desktop-pc (Clean)

**No prerequisites** — can rebuild immediately on a fresh WSL instance.

## Key Conventions

1. **Shell Configuration**: zsh is set as the default shell at system level (so it lands in `/etc/shells`) before Home Manager configures it.

2. **Rebuild Behavior**: Both `rebuild` and `hm` aliases in each machine call the same `nixos-rebuild` command. This simplifies the mental model for minimal configs where system and home are tightly coupled.

3. **Program Configuration**: User programs (taskwarrior, starship) are configured declaratively in `home.nix`. Package lists use `with pkgs;` for readability.

4. **State Version**: Both system and home configs are pinned to `25.05`. When upgrading NixOS releases, update both `stateVersion` values in lockstep.

## File Structure

```
flake.nix                           # Flake outputs (both machines)
hosts/
  daf-laptop/
    default.nix                     # NixOS system config (with corporate cert)
    home.nix                        # Home Manager config
  desktop-pc/
    default.nix                     # NixOS system config (clean)
    home.nix                        # Home Manager config
nvim-config/
  lua/                              # Neovim Lua config (shared)
```

## Common Tasks

### Adding a System Package

Edit `hosts/{machine}/default.nix` under `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  git
  curl
  # Add new packages here
];
rebuild
```

### Adding a User Package or Program

Edit `hosts/{machine}/home.nix`:
```nix
home.packages = with pkgs; [ ... ];
programs.program-name = {
  enable = true;
  # ... settings
};
rebuild
```

### Updating Dependencies

```bash
nix flake update              # Update all inputs to latest
rebuild                        # Apply changes
```

## Gotchas

- **Impure evaluation**: The `--impure` flag is required. Do not remove it.
- **daf-laptop certificate**: Will fail on first rebuild without `/etc/nixos/paccar-root.crt`.
- **Home Manager at system level**: Do not use `home-manager` CLI directly; it's integrated into `nixos-rebuild`.
