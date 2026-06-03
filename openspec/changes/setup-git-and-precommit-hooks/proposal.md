## Why

This project spans multiple machines (Daf work, Centric work, home desktop) and currently lacks standardized git configuration and code quality checks. Teams across different systems commit with inconsistent formatting, line endings, and editor settings. Pre-commit hooks will enforce standards automatically, catch issues before they enter the repository, and reduce friction in code review. Setting up `.gitattributes`, `.editorconfig`, and `.gitignore` ensures reproducible development environments and consistent tooling behavior across all machines.

## What Changes

- Add `.gitattributes` to enforce consistent line endings (LF for Nix files, CRLF handling for Windows WSL) and merge strategies for binary/append-only files
- Add `.editorconfig` to ensure consistent indentation, tab/space preferences, and line ending rules across editors (Neovim, VS Code, etc.)
- Add `.gitignore` to prevent accidental commits of machine-specific files, build artifacts, secrets, and temporary files
- Configure and integrate pre-commit hooks (via https://pre-commit.com/) to run automated checks on staged changes before commit
- Document pre-commit setup and local hook installation for all team members

## Capabilities

### New Capabilities

- `git-attributes-setup`: Configure line endings, merge strategies, and diff settings for all file types in the repository
- `editor-config-setup`: Standardize editor formatting rules (indentation, charset, line endings) via `.editorconfig`
- `gitignore-patterns`: Define patterns to ignore system files, build outputs, secrets, and machine-specific artifacts
- `precommit-hooks-integration`: Set up pre-commit framework with hooks for formatting, linting, and validation (Nix, YAML, JSON, Markdown, shell scripts)

### Modified Capabilities

<!-- No existing spec-level capability requirements are changing -->

## Impact

- **Affected files**: `.gitattributes` (new), `.editorconfig` (new), `.gitignore` (new), `.pre-commit-config.yaml` (new)
- **Affected processes**: Local development workflow, CI/CD pre-commit stage, code review expectations
- **Team-wide**: All three machines (Daf work, Centric work, home desktop) benefit from standardized tooling
- **Dependencies**: Requires `pre-commit` Python package (installed via pip or managed by Nix/home-manager), Git 2.11+
- **Breaking changes**: None (this is purely additive infrastructure)
