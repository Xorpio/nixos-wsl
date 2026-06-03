## ADDED Requirements

### Requirement: sops-nix manages encrypted secrets
Secrets (API keys, SSH credentials, machine-specific config) SHALL be managed with sops-nix, encrypted at rest, and decrypted by home-manager at deployment time.

#### Scenario: Secrets are encrypted in git
- **WHEN** developer examines `secrets/secrets.yaml`
- **THEN** file is encrypted and unreadable as plain text in the repository

#### Scenario: Secrets are available to applications at runtime
- **WHEN** home-manager rebuilds and deploys configuration
- **THEN** encrypted secrets are decrypted and made available to configured applications

### Requirement: Each machine has its own secrets
Each machine (daf-laptop, centric-laptop, home-desktop) SHALL have its own encrypted secrets file, decryptable only with that machine's local key.

#### Scenario: Per-machine secrets file
- **WHEN** Daf work laptop is set up
- **THEN** its secrets are in `secrets/daf-laptop/secrets.yaml` encrypted with daf-laptop's key

#### Scenario: Machine-specific credentials
- **WHEN** API keys differ between work and home environments
- **THEN** each machine's secrets file contains only its own credentials

#### Scenario: Key revocation
- **WHEN** a machine is decommissioned or compromised
- **THEN** that machine's `.key` file is deleted, rendering its secrets.yaml undecryptable

### Requirement: sops keys are NOT committed to git
Machine-specific sops keys (e.g., `secrets/daf-laptop/.sops.yaml.key`) SHALL be listed in `.gitignore` and never committed.

#### Scenario: .key files ignored
- **WHEN** developer runs `git status` after decryption
- **THEN** `.key` files do NOT appear in the status output

#### Scenario: Key files persist locally
- **WHEN** developer navigates `secrets/` directory on machine
- **THEN** `.key` files exist locally but are not tracked by git

### Requirement: sops configuration declares keys
A `.sops.yaml` file SHALL configure how sops encrypts/decrypts files for each machine.

#### Scenario: Per-machine encryption rule
- **WHEN** `secrets/daf-laptop/secrets.yaml` is encrypted
- **THEN** it uses the public key from `secrets/daf-laptop/.sops.yaml` configuration

### Requirement: Secrets are accessible to home-manager modules
sops-nix integration SHALL make secrets available to home-manager services and configurations.

#### Scenario: Git SSH key from secrets
- **WHEN** git is configured
- **THEN** SSH key path is resolved from decrypted secrets

#### Scenario: API credentials in environment
- **WHEN** a dev tool needs API credentials
- **THEN** home-manager reads from decrypted secrets and sets environment variables
