## ADDED Requirements

### Requirement: Single flake manages all machines
The system SHALL use a single `flake.nix` as the source of truth for all three machines (daf-laptop, centric-laptop, home-desktop), with a shared lock file (`flake.lock`).

#### Scenario: Flake declares all three hosts
- **WHEN** user runs `flake show`
- **THEN** output includes outputs for all three hostnames (daf-laptop, centric-laptop, home-desktop)

#### Scenario: Single lock file synchronizes versions
- **WHEN** a dependency is updated and lock file is committed
- **THEN** all three machines use the same version of that dependency after rebuild

### Requirement: Per-machine configuration isolation
Each machine (daf-laptop, centric-laptop, home-desktop) SHALL have its own directory under `hosts/<hostname>/` containing `system.nix`, `default.nix`, and `home.nix`.

#### Scenario: Machine-specific overrides
- **WHEN** daf-laptop needs different packages than centric-laptop
- **THEN** daf-laptop can specify packages in its own `hosts/daf-laptop/system.nix` without affecting centric-laptop

#### Scenario: Machines share default behavior
- **WHEN** all three machines use the same shell configuration
- **THEN** they reference the same shared module from `modules/shell/` rather than duplicating config

### Requirement: Flake inputs are well-defined
The `flake.nix` SHALL declare all inputs (nixpkgs, home-manager, sops-nix, etc.) with pinned versions in `flake.lock`.

#### Scenario: Adding a new input
- **WHEN** a new input needs to be added (e.g., a new Nix module)
- **THEN** it can be added to `flake.nix` inputs and `flake.lock` is automatically updated

### Requirement: Outputs are composable
The flake outputs for each machine SHALL combine system config, home-manager config, and shared modules into a complete configuration.

#### Scenario: Building a specific machine
- **WHEN** user runs `nixos-rebuild switch --flake .#daf-laptop`
- **THEN** the flake resolves `outputs.nixosConfigurations.daf-laptop` and applies that configuration
