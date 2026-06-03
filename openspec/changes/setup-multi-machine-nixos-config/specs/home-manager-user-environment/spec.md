## ADDED Requirements

### Requirement: Home-manager manages user environment
Home-manager SHALL manage the user environment (shell, editor, dev tools, dotfiles, environment variables) separately from system configuration.

#### Scenario: Deploy user environment changes
- **WHEN** user runs `home-manager switch --flake .#username@hostname`
- **THEN** user's dotfiles, shell config, and tools are updated without requiring sudo

#### Scenario: User config survives system rebuild
- **WHEN** system configuration is rebuilt with `nixos-rebuild switch`
- **THEN** user environment config remains unchanged unless explicitly modified

### Requirement: Each user-machine pair has own configuration
Each combination of username and machine SHALL have its own home-manager config at `hosts/<hostname>/home.nix`.

#### Scenario: Different users on same machine
- **WHEN** machine has multiple user accounts
- **THEN** each user can have their own home-manager configuration

#### Scenario: Same user, different machines
- **WHEN** user logs in on daf-laptop vs home-desktop
- **THEN** each machine applies the appropriate home-manager config for that hostname

### Requirement: Home-manager composes shared modules
Home-manager configs SHALL compose modules from `modules/` for shell, editor, dev tools, and other shared configurations.

#### Scenario: Shared shell configuration
- **WHEN** shell module is referenced in all three hosts
- **THEN** all machines get consistent shell setup (zsh, aliases, functions, etc.)

#### Scenario: Machine-specific overrides
- **WHEN** daf-laptop needs an additional tool beyond the shared config
- **THEN** it can extend the module or add the tool in its own home.nix

### Requirement: User environment is reproducible
Given a specific home-manager flake with a particular `flake.lock`, rebuilding SHALL produce identical user environments.

#### Scenario: Consistent environment across rebuilds
- **WHEN** user rebuilds home-manager config on the same machine with the same lock file
- **THEN** all packages, versions, and configurations are identical to the previous build
