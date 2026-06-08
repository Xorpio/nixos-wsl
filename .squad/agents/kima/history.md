# Kima — Project History

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
- `hosts/daf-laptop/default.nix` — NixOS system config (corporate, requires PACCAR root cert)
- `hosts/daf-laptop/home.nix` — Home Manager user config
- `hosts/desktop-pc/default.nix` — NixOS system config (clean)
- `hosts/desktop-pc/home.nix` — Home Manager user config

**Build Commands:**
```bash
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#daf-laptop
sudo nixos-rebuild switch --impure --flake ~/nixos-wsl#desktop-pc
```

**Key Convention:** Use `with pkgs; [ ... ]` syntax for package lists in nixos and home configs.

## Current Task

Implement SOPS integration:
1. Add SOPS as a flake input (decide on version/source)
2. Add SOPS tools to both system configs
3. Follow project conventions (simple, readable)
4. Await Lester's approval on architecture before implementing

## Learnings

(None yet — first session)
