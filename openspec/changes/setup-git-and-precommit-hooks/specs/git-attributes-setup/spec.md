## ADDED Requirements

### Requirement: Configure line endings for Nix and Unix files

The system SHALL use LF (Unix line endings) for all Nix, shell, YAML, JSON, and Markdown files to ensure consistency across Unix/Linux/WSL development.

#### Scenario: Nix files use LF line endings
- **WHEN** a `.nix` file is committed
- **THEN** Git normalizes it to LF line endings in the repository

#### Scenario: Shell scripts use LF line endings
- **WHEN** a shell script (`.sh` extension) is committed
- **THEN** Git normalizes it to LF line endings

#### Scenario: YAML and JSON files use LF line endings
- **WHEN** `.yaml`, `.yml`, or `.json` files are committed
- **THEN** Git normalizes them to LF line endings

### Requirement: Configure diff and merge settings for binary files

The system SHALL define appropriate diff and merge strategies for binary files to prevent corruption and spurious diffs.

#### Scenario: Binary files skip diff
- **WHEN** a binary file is included in a diff
- **THEN** Git shows "binary file" instead of attempting text comparison

#### Scenario: Binary files use theirs merge strategy
- **WHEN** a merge conflict occurs on a binary file
- **THEN** Git uses the current branch's version (theirs) to avoid merge errors

### Requirement: Configure merge strategy for append-only squad state files

The system SHALL use the `union` merge driver for Squad's append-only files (decisions.md, history.md, orchestration logs) to enable conflict-free merging across branches.

#### Scenario: Squad decisions file merges with union driver
- **WHEN** `.squad/decisions.md` is merged from two branches with additions from both
- **THEN** Git combines all lines from both branches without conflict

#### Scenario: Squad agent history merges with union driver
- **WHEN** `.squad/agents/*/history.md` is merged from two branches
- **THEN** Git combines all history entries from both branches

#### Scenario: Squad orchestration logs merge with union driver
- **WHEN** `.squad/orchestration-log/**` files are merged
- **THEN** Git combines log entries from both branches

### Requirement: Create and document .gitattributes file

The system SHALL provide a `.gitattributes` file at the repository root that defines the above rules.

#### Scenario: .gitattributes exists at repo root
- **WHEN** the repository is cloned
- **THEN** `.gitattributes` file exists at the repository root

#### Scenario: .gitattributes rules are applied by default
- **WHEN** a developer clones the repo and commits files
- **THEN** Git automatically applies `.gitattributes` rules without explicit configuration
