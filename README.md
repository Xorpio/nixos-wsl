# nixos-wsl

Multi-machine NixOS WSL configuration for integrated development environments across Daf work, Centric work, and home desktop machines.

## Local Development Setup

This repository uses pre-commit hooks to enforce code quality standards and prevent common mistakes before code is committed.

### Prerequisites

- Python 3.7 or newer
- Git 2.11 or newer
- `pip` (Python package manager)

### Installation

1. **Install pre-commit framework:**
   ```bash
   pip install --user pre-commit
   ```

2. **Install Git hooks:**
   ```bash
   cd nixos-wsl
   pre-commit install
   ```

   This one-time setup installs the pre-commit hooks into your Git repository. Hooks will now run automatically on every `git commit`.

### What Pre-Commit Hooks Do

Pre-commit hooks automatically check your staged changes before you commit them. They perform the following checks:

- **Line endings**: Enforce LF (Unix-style) line endings for most files
- **Trailing whitespace**: Remove trailing whitespace from files
- **File formatting**: Ensure files end with a newline
- **Large files**: Warn if you're committing files larger than 1 MB
- **Merge conflicts**: Detect files with unresolved merge conflicts
- **JSON validation**: Validate JSON file syntax
- **YAML validation**: Validate YAML file syntax
- **Shell scripts**: Check shell scripts for common errors (shellcheck)
- **Secret patterns**: Detect potential secrets or API keys

### Using Pre-Commit

#### Automatic checking on commit
Once installed, hooks run automatically when you commit:
```bash
git commit -m "Your commit message"
```

If any hooks fail, your commit is blocked. Fix the issues and try again:
```bash
# Fix issues if needed
git add .
git commit -m "Your commit message"
```

#### Manual verification
Run hooks on all files in the repository without committing:
```bash
pre-commit run --all-files
```

Run hooks on only staged files:
```bash
pre-commit run
```

#### Bypassing hooks (not recommended)
If you need to commit without running hooks (for example, to commit a work-in-progress), use:
```bash
git commit --no-verify
```

⚠️ **Note**: Bypassing hooks should only be done in exceptional cases. Hooks exist to maintain code quality and prevent problems downstream. It's better to fix issues than to skip checks.

### Configuration

- `.editorconfig`: Editor configuration for consistent indentation, line endings, and formatting across different editors (VS Code, Neovim, Sublime Text, etc.)
- `.gitattributes`: Git configuration for line ending normalization and merge strategies
- `.gitignore`: Patterns for files that should not be committed (build artifacts, secrets, temporary files)
- `.pre-commit-config.yaml`: Configuration for pre-commit hooks

### Supported Editors

EditorConfig rules are supported by most popular editors:

- **VS Code**: Install the [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) extension
- **Neovim**: EditorConfig support is available via the `editorconfig-nvim` plugin
- **Sublime Text**: EditorConfig is built-in
- **JetBrains IDEs** (IntelliJ, PyCharm, etc.): EditorConfig support is built-in
- **Vim**: Install the `editorconfig-vim` plugin

### Troubleshooting

#### "pre-commit: command not found"
The `pre-commit` command is not in your PATH. Try:
```bash
python -m pre_commit --version
```

If that works, you can use `python -m pre_commit` instead of `pre-commit` for all commands. To add it to your PATH permanently, ensure your Python user scripts directory is in your PATH environment variable.

#### Hooks fail on my machine
Common issues and solutions:

1. **Line ending problems on Windows**: Git may be set to auto-convert line endings. Ensure `.gitattributes` is configured correctly and run:
   ```bash
   git config core.safecrlf true
   ```
   This will warn if there are mixed line endings.

2. **Python module not found**: Re-install pre-commit:
   ```bash
   pip install --user --upgrade pre-commit
   ```

3. **Hooks take too long**: Some hooks (like shell linting) can be slow on large repositories. This is normal on first run. Subsequent runs are faster because pre-commit caches results.

### Line Ending Normalization and Windows

This repository is configured to use LF (Unix-style) line endings for all text files. Windows uses CRLF line endings by default, which can cause spurious diff changes.

**On Windows (including WSL):**
- `.gitattributes` automatically handles line ending conversion
- `.editorconfig` enforces LF line endings
- Pre-commit checks enforce these rules

If you see unexpected line ending changes, verify your Git config:
```bash
git config core.safecrlf true
```

### Per-Machine Setup (Optional)

If you use home-manager on all machines, you can automate pre-commit installation. See the home-manager configuration for details on enabling pre-commit hooks automatically.

### Further Reading

- [Pre-commit Framework Documentation](https://pre-commit.com/)
- [EditorConfig Documentation](https://editorconfig.org/)
- [Git Attributes Documentation](https://git-scm.com/docs/gitattributes)
