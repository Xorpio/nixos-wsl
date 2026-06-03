## Context

This nixos-wsl repository spans three separate machines (Daf work, Centric work, home desktop), each potentially using different editors and operating systems (Windows WSL). Currently, there is no unified approach to:
- Line ending normalization across platforms
- Code formatting and editor configuration
- Preventing accidental commits of secrets, build artifacts, or machine-specific files
- Enforcing code quality checks before commit

Each developer is responsible for remembering to run linters and formatters manually, leading to inconsistent commit history and review friction. Pre-commit hooks automate this, reducing friction and catching issues before they enter the repository.

## Goals / Non-Goals

**Goals:**
- Standardize line endings (LF for Nix files, consistent handling for text files)
- Enforce consistent editor behavior (indentation, charset, trailing whitespace) across all machines
- Prevent accidental commits of sensitive files, build outputs, and machine-specific state
- Automate pre-commit checks (formatting, linting, YAML/JSON validation, shell script checks, Nix checks where applicable)
- Document setup so new machines can quickly adopt the configuration
- Ensure checks run locally before code reaches CI/CD

**Non-Goals:**
- Replace CI/CD linting — pre-commit hooks are a first-pass defense, not a replacement for CI
- Enforce specific coding style (that's handled by language-specific linters referenced in pre-commit)
- Manage secrets storage (sops-nix already handles that; `.gitignore` just prevents accidents)
- Create a full Git workflow (hooks, commit message validation, etc. beyond pre-commit)

## Decisions

**1. Use `.gitattributes` for line ending normalization and merge strategies**

- **Decision**: Add `.gitattributes` with rules for LF (Nix), CRLF (Windows batch/PS), and auto-detection for others
- **Why**: WSL and native Windows tools have different expectations. LF is standard for Nix/Unix. Explicit rules prevent mixed line endings in version control.
- **Alternatives considered**:
  - Global Git config (`core.autocrlf true`) — too coarse, doesn't capture per-repo differences
  - No line ending standardization — leads to merge conflicts and spurious diffs
- **Decision**: Also use `.gitattributes` for `merge=union` on append-only `.squad/` files to enable conflict-free merging across branches
- **Why**: Drop-box pattern (Squad's shared-state architecture) relies on automatic merging of append-only logs and decision files

**2. Use `.editorconfig` for cross-tool formatting consistency**

- **Decision**: Add `.editorconfig` with rules for indentation (spaces/tabs), charset (UTF-8), line endings, and trailing whitespace
- **Why**: Neovim, VS Code, and other editors all support `.editorconfig`. One file rules them all without requiring per-editor configuration.
- **Alternatives considered**:
  - Per-tool config files (`.vimrc`, `.prettierrc`, `.eslintrc`, etc.) — creates maintenance burden and requires tool-specific knowledge
  - Manual documentation — developers forget; `.editorconfig` is enforced automatically
- **Decision**: Conservative defaults (2-space indentation for most files, tabs for Makefiles)
- **Why**: Nix convention is 2-space indentation; keeps consistent with existing codebase if any

**3. Use `.gitignore` with platform-aware patterns**

- **Decision**: Comprehensive `.gitignore` covering:
  - OS/IDE: `.vscode/`, `.idea/`, `.DS_Store`, Thumbs.db, `*.swp`, `*.swo`
  - Language-specific: `node_modules/`, `*.o`, `*.so`, `dist/`, `build/`
  - Machine/secrets: `.sops*` (sops-nix .key files), `*.env.local`, machine-specific SSH keys
  - Nix: `result`, `result-*`, `.dirlocal` (for nix-direnv if added)
- **Why**: Prevents accidental commits while staying focused on what we actually don't want in git
- **Alternatives considered**:
  - Multiple `.gitignore` files per directory — harder to maintain, easy to miss a pattern
  - No `.gitignore` — relies on developer discipline, error-prone
- **Decision**: One `.gitignore` at repo root (checked via `git check-ignore` before implementing specifics)

**4. Use pre-commit.com framework for hook orchestration**

- **Decision**: Install `pre-commit` via pip/Nix and use `.pre-commit-config.yaml` to define hooks
- **Why**: Language-agnostic, declarative YAML config, large ecosystem of well-maintained hooks, easy local installation
- **Alternatives considered**:
  - Manual Git hooks in `.git/hooks/` — no version control, no easy multi-machine sync, maintenance nightmare
  - GitHub Actions only — doesn't catch issues before push, too late for developer experience
  - husky (JavaScript-specific) — overkill for a Nix-centric repo, language-specific
- **Decision**: Include hooks for Nix, YAML, JSON, Markdown, shell scripts, and general formatting
- **Why**: Matches the repo's primary languages and tooling; catch common mistakes early

**5. Document pre-commit setup in README and per-machine**

- **Decision**: Add section to README with: `pip install pre-commit`, `pre-commit install` steps
- **Why**: New machines need quick onboarding without hunting through docs
- **Alternatives considered**:
  - Include pre-commit in home-manager config — more integration, but adds complexity to Nix setup
  - Assume developers know pre-commit — not safe; explicit documentation is essential
- **Decision**: Keep it optional (pre-commit not required by CI, just recommended locally)
- **Why**: Some environments (CI, containers) may need to bypass hooks; CI should re-run checks independently

## Risks / Trade-offs

- **Risk**: Pre-commit adds a few seconds to every commit. Developers might be tempted to bypass hooks (`git commit --no-verify`).
  - **Mitigation**: Hooks are fast (< 1s for most commits). Document the purpose so developers understand the value. Hooks can be skipped if urgent, but should be run before pushing.

- **Risk**: `.pre-commit-config.yaml` pins specific hook versions. If a hook breaks or is deprecated, the config needs updates.
  - **Mitigation**: Use hooks from well-maintained sources (pre-commit.com ecosystem). Set up periodic dependency updates (e.g., weekly dependabot for `.pre-commit-config.yaml`).

- **Risk**: WSL + Windows line ending expectations conflict. Git's autocrlf can cause mixed results.
  - **Mitigation**: `.gitattributes` explicitly defines rules per file type. Developers should run `git config core.safecrlf true` to catch mixed line endings early.

- **Risk**: Not all machines may have pre-commit installed (e.g., quick CI runner). Hooks need to be optional, not blocking.
  - **Mitigation**: Pre-commit is documented as "strongly recommended" but not required. CI runs equivalent checks independently.

## Migration Plan

1. **Phase 1 (Setup)**: Create `.gitattributes`, `.editorconfig`, `.gitignore`, `.pre-commit-config.yaml` at repo root
2. **Phase 2 (Local adoption)**: Developers run `pre-commit install` in their local checkouts (one-time setup)
3. **Phase 3 (Validation)**: Pre-commit hooks run on their next `git commit`
4. **Phase 4 (Cleanup)**: Optional: run `pre-commit run --all-files` to fix any existing issues in the repo (may be done in a separate commit if needed)
5. **Phase 5 (Documentation)**: Update README with setup steps and troubleshooting

## Open Questions

- Should we include Nix-specific hooks (e.g., `nixfmt` for formatting)? Depends on whether Nix files in the repo should be auto-formatted.
- Should we run pre-commit in CI as a gate (required to pass before merge)? Or just recommend it locally?
- Are there team-specific secrets patterns that should go in `.gitignore` beyond the defaults (sops keys)?
