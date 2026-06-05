# Lester — Project History

## Project: nixos-wsl

**Stack:** NixOS 25.05, Home Manager, Flakes
**User:** Niek de Gooijer
**Goal:** Multi-machine NixOS WSL configurations with SOPS secrets management

### Architecture Context

**Flake Structure (`flake.nix`):**
- Inputs: `nixpkgs` (25.05), `home-manager` (25.05 release), `nixos-wsl`
- Outputs: `nixosConfigurations.daf-laptop`, `homeConfigurations."daf@daf-laptop"`, `nixosConfigurations.desktop-pc`, `homeConfigurations."daf@desktop-pc"`
- Home Manager integrated at system level: `home-manager.useGlobalPkgs = true; home-manager.useUserPackages = true`

**Machine-Specific Configs:**
- `hosts/daf-laptop/default.nix` — NixOS system config (corporate, requires PACCAR root cert at `/etc/nixos/paccar-root.crt`)
- `hosts/daf-laptop/home.nix` — Home Manager user config
- `hosts/desktop-pc/default.nix` — NixOS system config (clean, no corporate deps)
- `hosts/desktop-pc/home.nix` — Home Manager user config

**Build Commands:**
```bash
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc
```

Shell aliases: `rebuild` and `hm` (same as rebuild for that machine).

**State Version:** Both system and home pinned to 25.05. Update in lockstep when upgrading.

## Current Task

Install and integrate SOPS (Secrets Operations) into the flake for both systems:
1. Add SOPS as a flake input
2. Integrate SOPS tooling into system packages (nixos-rebuild gets the tools)
3. Integrate into both `daf-laptop` and `desktop-pc` configs
4. Validate rebuilds work on both machines

## Learnings

(None yet — first session)
