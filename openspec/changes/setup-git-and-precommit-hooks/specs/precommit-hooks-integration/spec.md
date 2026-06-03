## ADDED Requirements

### Requirement: Configure pre-commit framework

The system SHALL provide a `.pre-commit-config.yaml` file that defines which pre-commit hooks run and when.

#### Scenario: .pre-commit-config.yaml exists at repo root
- **WHEN** the repository is cloned
- **THEN** `.pre-commit-config.yaml` file exists at the repository root

#### Scenario: Pre-commit framework can be installed locally
- **WHEN** a developer runs `pip install pre-commit` and `pre-commit install`
- **THEN** Git hooks are installed in the local `.git/hooks/` directory

#### Scenario: Pre-commit hooks run on git commit
- **WHEN** a developer runs `git commit`
- **THEN** pre-commit hooks are invoked on staged files

#### Scenario: Pre-commit can be run manually on all files
- **WHEN** a developer runs `pre-commit run --all-files`
- **THEN** all configured hooks run against all tracked files in the repository

### Requirement: Validate YAML and JSON files

The system SHALL include pre-commit hooks that validate YAML and JSON syntax to catch formatting errors before commit.

#### Scenario: YAML syntax is validated
- **WHEN** a `.yaml` or `.yml` file is staged
- **THEN** the YAML validation hook runs and fails if syntax is invalid

#### Scenario: JSON syntax is validated
- **WHEN** a `.json` file is staged
- **THEN** the JSON validation hook runs and fails if syntax is invalid

#### Scenario: YAML and JSON validation hooks are fast
- **WHEN** pre-commit runs validation hooks
- **THEN** hooks complete in under 1 second for typical commits

### Requirement: Format and lint code files

The system SHALL include pre-commit hooks for formatting and linting shell scripts, Markdown, and other text files.

#### Scenario: Shell scripts are linted with ShellCheck
- **WHEN** a shell script (`.sh`) is staged
- **THEN** ShellCheck runs and flags potential issues

#### Scenario: Markdown files are checked for formatting
- **WHEN** a Markdown file (`.md`) is staged
- **THEN** a Markdown linter runs (e.g., markdownlint)

#### Scenario: Files are checked for trailing whitespace
- **WHEN** any file is staged
- **THEN** pre-commit checks for and fails if trailing whitespace is found

#### Scenario: Line endings are normalized
- **WHEN** files are staged
- **THEN** pre-commit ensures line endings are correct (LF for Unix, as per `.gitattributes`)

### Requirement: Prevent secrets from being committed

The system SHALL include a hook to detect and prevent common patterns of secrets (API keys, credentials, private data).

#### Scenario: Common secret patterns are detected
- **WHEN** a file containing patterns like `private_key`, `password=`, or `AKIA` (AWS) is staged
- **THEN** the detect-secrets hook fails and prevents commit

#### Scenario: False positives can be allowed with user acknowledgment
- **WHEN** a developer intentionally needs to commit a file with a secret pattern (e.g., test data)
- **THEN** they can use `.gitignore` or bypass hooks with `--no-verify` (documented)

### Requirement: Document pre-commit setup for team members

The system SHALL provide documentation so developers can easily set up pre-commit hooks locally.

#### Scenario: README includes pre-commit setup instructions
- **WHEN** a developer reads the README
- **THEN** they see steps: `pip install pre-commit` → `pre-commit install`

#### Scenario: Pre-commit setup is a one-time operation per clone
- **WHEN** a developer clones the repo and runs `pre-commit install`
- **THEN** they do not need to repeat the setup on subsequent commits in that clone

#### Scenario: Pre-commit can be bypassed if needed
- **WHEN** a developer runs `git commit --no-verify`
- **THEN** pre-commit hooks are skipped (documented as "use with caution")

### Requirement: Ensure pre-commit is optional but recommended

The system SHALL configure pre-commit as a local development tool (not a CI requirement) so developers benefit without blocking CI.

#### Scenario: Pre-commit is not required in CI
- **WHEN** a developer pushes code without running pre-commit locally
- **THEN** CI can still run (pre-commit checks will be re-run in CI for validation)

#### Scenario: Documentation recommends pre-commit but does not enforce it
- **WHEN** a developer reads the README
- **THEN** they see pre-commit as "strongly recommended" for local development

#### Scenario: Pre-commit hooks fail gracefully on unsupported environments
- **WHEN** pre-commit is not installed on a machine
- **THEN** commits still work (pre-commit is optional)
