## ADDED Requirements

### Requirement: Ignore OS and editor-specific files

The system SHALL ignore files and directories created by operating systems (Windows, macOS, Linux) and common editors (VS Code, Vim, Neovim, IntelliJ).

#### Scenario: macOS system files are ignored
- **WHEN** a `.DS_Store` file is present in the working directory
- **THEN** Git does not track it or prompt to add it

#### Scenario: Windows system files are ignored
- **WHEN** `Thumbs.db` or `desktop.ini` files are created
- **THEN** Git does not track them

#### Scenario: VS Code settings are ignored
- **WHEN** the `.vscode/` directory is created
- **THEN** Git does not track it (user-specific workspace settings remain local)

#### Scenario: Vim/Neovim swap files are ignored
- **WHEN** editor swap files (`.swp`, `.swo`) are created
- **THEN** Git does not track them

#### Scenario: IntelliJ IDE files are ignored
- **WHEN** `.idea/` directory is created
- **THEN** Git does not track IDE-specific project settings

### Requirement: Ignore build artifacts and compiled outputs

The system SHALL ignore files generated during build processes to keep the repository clean.

#### Scenario: Compiled object files are ignored
- **WHEN** C/C++ object files (`.o`, `.obj`) are compiled
- **THEN** Git does not track them

#### Scenario: Shared library files are ignored
- **WHEN** `.so` or `.dll` files are created
- **THEN** Git does not track them

#### Scenario: Nix build outputs are ignored
- **WHEN** Nix commands create `result` or `result-*` symlinks
- **THEN** Git does not track them

#### Scenario: Node modules are ignored
- **WHEN** `npm install` creates `node_modules/` directory
- **THEN** Git does not track it (dependencies are managed via `package-lock.json`)

#### Scenario: Build directories are ignored
- **WHEN** build systems create `build/`, `dist/`, or `target/` directories
- **THEN** Git does not track them

### Requirement: Ignore machine-specific and secret files

The system SHALL ignore files that contain machine-specific configuration, credentials, or secrets to prevent accidental commits.

#### Scenario: sops-nix key files are ignored
- **WHEN** sops-nix creates `.sops.yaml.key` files (per-machine encryption keys)
- **THEN** Git does not track them (secrets remain local)

#### Scenario: Environment variable files are ignored
- **WHEN** `.env`, `.env.local`, or `.env.*.local` files are created
- **THEN** Git does not track them (environment-specific configuration remains local)

#### Scenario: SSH keys and credentials are ignored
- **WHEN** SSH private keys or credential files are present
- **THEN** Git does not track them

### Requirement: Create and distribute .gitignore file

The system SHALL provide a `.gitignore` file at the repository root that prevents accidental commits of unwanted files.

#### Scenario: .gitignore exists at repo root
- **WHEN** the repository is cloned
- **THEN** `.gitignore` file exists at the repository root

#### Scenario: .gitignore rules are applied by default
- **WHEN** a developer runs `git status` or `git add`
- **THEN** Git automatically applies `.gitignore` rules without explicit configuration

#### Scenario: Developers can check patterns with git check-ignore
- **WHEN** a developer runs `git check-ignore <file>`
- **THEN** Git reports whether the file matches any pattern in `.gitignore`
