## ADDED Requirements

### Requirement: Standardize indentation and whitespace across tools

The system SHALL define consistent indentation (spaces vs. tabs), tab width, and trailing whitespace behavior in `.editorconfig` so all editors apply the same rules.

#### Scenario: Indentation is 2 spaces for most files
- **WHEN** a developer edits a file in any editor supporting `.editorconfig`
- **THEN** indentation is set to 2 spaces (not tabs)

#### Scenario: Makefiles use tab indentation
- **WHEN** a developer edits a `Makefile`
- **THEN** indentation is set to tabs (required for Makefiles)

#### Scenario: Trailing whitespace is removed
- **WHEN** a file is saved in an `.editorconfig`-aware editor
- **THEN** trailing whitespace is automatically removed from all lines

### Requirement: Ensure consistent charset and line ending rules

The system SHALL define UTF-8 charset and line ending (LF) rules in `.editorconfig` for all text files.

#### Scenario: All text files use UTF-8 charset
- **WHEN** a new file is created in an `.editorconfig`-aware editor
- **THEN** the charset is set to UTF-8

#### Scenario: All text files use LF line endings
- **WHEN** a file is edited or saved in an `.editorconfig`-aware editor
- **WHEN** the platform is Windows (WSL)
- **THEN** line endings are normalized to LF (not CRLF)

### Requirement: Configure file-type-specific rules

The system SHALL define specific indentation and whitespace rules for different file types (YAML, JSON, shell scripts, Nix) to match language conventions.

#### Scenario: YAML files are formatted with 2-space indentation
- **WHEN** a `.yaml` or `.yml` file is edited
- **THEN** indentation is set to 2 spaces

#### Scenario: JSON files are formatted with 2-space indentation
- **WHEN** a `.json` file is edited
- **THEN** indentation is set to 2 spaces

#### Scenario: Shell scripts use consistent indentation
- **WHEN** a shell script is edited
- **THEN** indentation is set to 2 spaces (configurable per script style)

#### Scenario: Nix files use consistent indentation
- **WHEN** a `.nix` file is edited
- **THEN** indentation is set to 2 spaces (Nix convention)

### Requirement: Create and distribute .editorconfig file

The system SHALL provide a `.editorconfig` file at the repository root that all editors can discover and apply automatically.

#### Scenario: .editorconfig exists at repo root
- **WHEN** the repository is cloned
- **THEN** `.editorconfig` file exists at the repository root

#### Scenario: Editors discover and apply .editorconfig rules
- **WHEN** a developer opens a file in an `.editorconfig`-aware editor (VS Code, Neovim, etc.)
- **THEN** the editor automatically applies the rules without additional configuration

#### Scenario: Developers can override .editorconfig locally if needed
- **WHEN** a developer's editor is configured to override `.editorconfig` rules
- **THEN** the local override takes precedence (e.g., personal `.vimrc` settings)
