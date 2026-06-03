# Contributing Guide

This guide provides guidelines for contributing to the nixos-wsl repository, including development workflow, code style, and best practices.

## Table of Contents

1. [Before You Start](#before-you-start)
2. [Development Workflow](#development-workflow)
3. [Code Style & Standards](#code-style--standards)
4. [Testing Changes](#testing-changes)
5. [Commit Messages](#commit-messages)
6. [Pull Requests](#pull-requests)
7. [Shared Modules](#shared-modules)
8. [Adding Features](#adding-features)
9. [Documentation](#documentation)

---

## Before You Start

### Understanding the Repository

Before contributing, understand the key concepts:

- **Flakes**: Nix package manager's declarative input system
- **Home-Manager**: Tool for managing user dotfiles and packages
- **Modules**: Reusable configuration units
- **Sops-nix**: Secrets encryption and management
- **Age**: Modern encryption tool for secrets

### Get Familiar With

1. Read [README.md](README.md) - Overview and architecture
2. Read [TESTING.md](TESTING.md) - How to test changes
3. Read [DEPLOYMENT.md](DEPLOYMENT.md) - How to deploy
4. Explore `hosts/*/home.nix` - Per-machine configs
5. Explore `modules/*/default.nix` - Shared modules

### Prerequisites

```bash
# Nix environment
nix --version                          # Should be 2.16.0+

# Git
git --version                          # Should be 2.30+
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Pre-commit (for hook enforcement)
pip install --user pre-commit
cd /path/to/nixos-wsl
pre-commit install
```

---

## Development Workflow

### 1. Create Feature Branch

Use descriptive branch names following this pattern:

```bash
git checkout -b <type>/<description>
```

**Branch types**:
- `feature/` - New feature or capability
- `fix/` - Bug fix
- `refactor/` - Code reorganization
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks

**Examples**:
```bash
git checkout -b feature/add-rust-lsp
git checkout -b fix/neovim-plugin-loading
git checkout -b docs/improve-secrets-guide
git checkout -b refactor/shell-module
```

### 2. Make Changes

Edit files according to the change type:

**For module changes** (affects multiple machines):
```bash
# Edit the shared module
vim modules/shell/default.nix

# Test on primary machine first
home-manager switch --flake '.#daf@daf-laptop' --dry-run
home-manager switch --flake '.#daf@daf-laptop'
```

**For per-machine changes**:
```bash
# Edit machine configuration
vim hosts/daf-laptop/home.nix

# Test just that machine
home-manager switch --flake '.#daf@daf-laptop'
```

**For documentation changes**:
```bash
# Edit markdown files
vim CONTRIBUTING.md
vim TESTING.md

# Check markdown format
pre-commit run --all-files
```

### 3. Verify Changes

Before committing:

```bash
# Test on your machine
home-manager switch --flake '.#USER@HOSTNAME' --dry-run

# If looks good, apply
home-manager switch --flake '.#USER@HOSTNAME'

# Test functionality
exec $SHELL -l                         # Reload shell
nvim --version                         # Check editor
which <new-tool>                       # Check new packages
```

### 4. Commit Changes

```bash
# Stage changes
git add <files>
git add modules/shell/default.nix

# Pre-commit hooks run automatically
# If hooks fail, fix issues and try again
git commit -m "Add feature or fix"

# If needed, bypass hooks (not recommended)
git commit --no-verify
```

### 5. Push & Create PR

```bash
# Push branch
git push origin <branch-name>

# Create pull request on GitHub
# Include description of changes
```

---

## Code Style & Standards

### Nix Code Style

Follow these conventions for Nix files:

#### Indentation
```nix
# Use 2-space indentation (NO TABS)
{ config, lib, pkgs, ... }:
{
  options = {
    myOption = ...;
  };

  config = {
    # 2-space indent
    home.packages = with pkgs; [
      package1
      package2
    ];
  };
}
```

#### Function Definitions
```nix
# Format functions clearly
let
  # Helper function
  formatName = name: "formatted-${name}";
in
{
  # Use meaningful names
  options.modules.mymodule.enable = ...;
}
```

#### Attribute Sets
```nix
# Consistent formatting for attribute sets
{
  option1 = value1;
  option2 = value2;
  
  nested = {
    innerOption = value3;
  };
}
```

### Lua Code Style (Neovim)

For Neovim Lua configuration:

#### Indentation
```lua
-- Use 2-space indentation
local M = {}

function M.setup()
  local config = {
    option1 = true,
    option2 = false,
  }
end

return M
```

#### Naming
```lua
-- Use snake_case for variables
local config_options = { }

-- Use PascalCase for classes/modules
local MyModule = { }

-- Use UPPER_SNAKE_CASE for constants
local MAX_RETRIES = 3
```

#### Comments
```lua
-- Use clear, descriptive comments
-- Explain WHY, not WHAT (code shows what)

-- Setup LSP configuration
-- This enables language server protocol support
-- for multiple languages via nvim-lspconfig
```

### Shell Script Style (Bash)

For shell scripts:

```bash
#!/bin/bash
# Use shebang for clarity

set -euo pipefail    # Exit on error, undefined var, pipe fail

# Use meaningful variable names
readonly config_dir="$HOME/.config"

# Use functions for reusability
verify_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file" >&2
    return 1
  fi
}

# Use clear error messages
if ! verify_file "$config_file"; then
  exit 1
fi
```

### Documentation Style

For Markdown documentation:

#### Structure
```markdown
# Top-level heading

## Sections

### Subsections

#### Sub-subsections

Brief intro paragraph...

### Code Examples

Include copyable examples

    code example here

## Links

Link to [other docs](DEPLOYMENT.md) when relevant
```

#### Formatting
```markdown
**Bold** for emphasis
`code` for inline code
```bash
code block for commands
```

- Use bullet lists for options
- Numbered for procedures

| Column 1 | Column 2 |
|----------|----------|
| Data     | Data     |
```

---

## Testing Changes

### Before Committing

Always test changes before committing:

### 1. Dry-Run

```bash
# See what would change
home-manager switch --flake '.#USER@HOSTNAME' --dry-run

# Review output:
# - New packages to install?
# - Files to create/modify?
# - Errors or warnings?
```

### 2. Apply & Verify

```bash
# Apply changes
home-manager switch --flake '.#USER@HOSTNAME'

# Verify specific functionality
exec $SHELL -l                    # Test shell
nvim --version                    # Test editor
which <new-package>               # Test new packages
alias <alias-name>                # Test aliases
```

### 3. Rollback if Issues

```bash
# If something breaks
home-manager switch --switch-generation -1

# Fix the issue
vim hosts/daf-laptop/home.nix
vim modules/shell/default.nix

# Try again
home-manager switch --flake '.#USER@HOSTNAME'
```

### Test Checklist

For each type of change:

**Module changes** (shell, neovim, git, etc.):
- [ ] Dry-run on primary machine
- [ ] Apply to primary machine
- [ ] Test specific functionality
- [ ] Can rollback if needed

**Per-machine changes**:
- [ ] Dry-run on target machine
- [ ] Apply to target machine
- [ ] Verify machine-specific features

**Documentation changes**:
- [ ] Pre-commit hooks pass
- [ ] Markdown renders correctly
- [ ] Links work correctly
- [ ] Code examples are accurate

**Secrets changes**:
- [ ] Can encrypt: `sops secrets/hostname/secrets.yaml`
- [ ] Can decrypt: `sops -d secrets/hostname/secrets.yaml`
- [ ] No plaintext secrets committed

---

## Commit Messages

### Commit Message Format

Follow this format for clear history:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Subject Line

- Imperative mood ("add" not "added" or "adds")
- No period at end
- Capitalize first letter
- Maximum 50 characters

### Type

Use one of:
- **feat**: New feature
- **fix**: Bug fix
- **refactor**: Code reorganization
- **docs**: Documentation
- **test**: Test additions/changes
- **chore**: Build/tooling/dependencies
- **ci**: CI/CD changes

### Scope

Optional, indicates what changed:
- `shell` - shell module
- `neovim` - neovim module
- `git` - git module
- `daf-laptop` - machine config
- etc.

### Examples

```
feat(neovim): Add nvim-dap debugger support

Add debugging support via nvim-dap and nvim-dap-ui.
This enables debugging in Neovim for supported languages.

Adds default DAP keybindings and configuration.

Closes #42
```

```
fix(shell): Correct alias for grep colors

The grep alias wasn't enabling colors properly.
Use --color=auto for POSIX compatibility.
```

```
docs: Improve CONTRIBUTING guide

Add more examples for commit messages and code style.
Clarify testing procedures before committing.
```

---

## Pull Requests

### PR Title & Description

**Title Format**:
```
[Type] Brief description
```

Examples:
```
[Feature] Add Rust LSP support to Neovim
[Fix] Correct shell alias for grep colors
[Docs] Update deployment guide with examples
```

**Description Template**:
```markdown
## Description

Brief description of changes.

## Type of Change

- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring

## Testing

Describe how you tested changes:
- [ ] Tested on daf-laptop
- [ ] Tested on centric-laptop
- [ ] Verified with dry-run
- [ ] Manually tested functionality

## Checklist

- [ ] Pre-commit hooks pass
- [ ] Tested changes thoroughly
- [ ] Documentation updated (if needed)
- [ ] No secrets committed
- [ ] Rollback tested (for breaking changes)

## Issues

Closes #123
```

### PR Review Process

1. **Author** creates PR from feature branch
2. **Reviewers** check:
   - Code style compliance
   - Testing completeness
   - Documentation clarity
   - No secrets committed
3. **Author** addresses feedback
4. **Maintainer** merges to main

### PR Checklist

Before requesting review:
- [ ] Branch created from main
- [ ] All commits have clear messages
- [ ] Pre-commit hooks pass
- [ ] Changes tested thoroughly
- [ ] Dry-run reviewed
- [ ] Documentation updated
- [ ] No uncommitted changes
- [ ] No merge conflicts with main

---

## Shared Modules

When modifying shared modules, follow these guidelines:

### Module Structure

```nix
# modules/mymodule/default.nix
{ config, lib, pkgs, inputs, ... }:

with lib;
{
  options.modules.mymodule = {
    enable = mkEnableOption "mymodule";
    
    option1 = mkOption {
      type = types.str;
      default = "default-value";
      description = "What this option does";
    };
  };

  config = mkIf config.modules.mymodule.enable {
    # Your configuration here
    home.packages = with pkgs; [ ];
  };
}
```

### Module Best Practices

1. **Options should be documented**
   ```nix
   description = "What this option does and why you'd want it";
   ```

2. **Provide sensible defaults**
   ```nix
   default = "reasonable-default-value";
   ```

3. **Make it composable**
   ```nix
   # Allow additional items to be added
   additionalAliases = mkOption {
     type = types.attrsOf types.str;
     default = { };
     description = "Additional aliases beyond defaults";
   };
   ```

4. **Test across machines**
   ```bash
   # Test on all machines before merging
   home-manager switch --flake '.#daf@daf-laptop'
   home-manager switch --flake '.#centric@centric-laptop'
   home-manager switch --flake '.#nixos@home-desktop'
   ```

### Module Documentation

Document modules inline:

```nix
# modules/shell/default.nix
# Shell configuration module
#
# Provides zsh or bash configuration with aliases and
# environment variables.
#
# Usage:
#   modules.shell = {
#     enable = true;
#     defaultShell = "zsh";
#     additionalAliases.myalias = "command";
#   };
```

---

## Adding Features

### New Package

To add a new package:

```bash
# 1. Edit appropriate location
vim hosts/daf-laptop/home.nix          # Per-machine
# or
vim modules/shell/default.nix          # Shared across machines

# 2. Add to home.packages
home.packages = with pkgs; [
  existing-package
  new-package-name
];

# 3. Test
home-manager switch --flake '.#USER@HOSTNAME'
which new-package-name

# 4. Commit
git add modules/
git commit -m "feat(shell): Add new-package-name"
```

### New Module

To create a new shared module:

```bash
# 1. Create module directory
mkdir -p modules/newmodule

# 2. Create module file
cat > modules/newmodule/default.nix << 'EOF'
{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.newmodule = {
    enable = mkEnableOption "newmodule";
  };

  config = mkIf config.modules.newmodule.enable {
    # Your configuration
  };
}
EOF

# 3. Import in hosts/*/home.nix
# imports = [
#   ../../modules/newmodule
# ];

# 4. Enable in configuration
# modules.newmodule.enable = true;

# 5. Test on all machines
home-manager switch --flake '.#daf@daf-laptop'
home-manager switch --flake '.#centric@centric-laptop'
home-manager switch --flake '.#nixos@home-desktop'

# 6. Commit
git add modules/newmodule
git add hosts/*/home.nix
git commit -m "feat: Add newmodule"
```

### New Machine

To add support for a new machine:

```bash
# 1. Create machine directory
mkdir -p hosts/new-machine

# 2. Create configuration files
cat > hosts/new-machine/home.nix << 'EOF'
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ../../modules/shell
    ../../modules/neovim
    ../../modules/git
  ];

  modules.shell.enable = true;
  home.username = "newuser";
  home.homeDirectory = "/home/newuser";
}
EOF

# 3. Generate age key
mkdir -p secrets/new-machine
age-keygen -o secrets/new-machine/.key

# 4. Add public key to .sops.yaml
age-keygen -y secrets/new-machine/.key
# Copy output to .sops.yaml

# 5. Create encrypted secrets
sops secrets/new-machine/secrets.yaml

# 6. Update flake.nix (if using nixosConfigurations)
# Add: new-machine = mkHostConfig "new-machine" hosts.new-machine;

# 7. Test
nix flake show
home-manager switch --flake '.#newuser@new-machine'

# 8. Commit
git add hosts/new-machine/ secrets/new-machine/
git add .sops.yaml
git add flake.nix
git commit -m "feat: Add new-machine configuration"
```

---

## Documentation

### Updating Documentation

When making changes, update related documentation:

| Change | Update |
|--------|--------|
| Add package | Update README.md Features section |
| New module | Add to modules list in README.md |
| New machine | Update Machines table in README.md |
| New secret | Update secrets/README.md |
| New process | Add to DEPLOYMENT.md or TESTING.md |

### Documentation Checklist

- [ ] README.md updated (if feature added)
- [ ] CONTRIBUTING.md updated (if process changed)
- [ ] TESTING.md updated (if testing procedure changed)
- [ ] DEPLOYMENT.md updated (if deployment changed)
- [ ] Inline comments added (for complex code)
- [ ] Examples provided (for new features)

### Good Documentation

✅ DO:
- Include practical examples users can copy/paste
- Explain WHY, not just WHAT
- Keep related information together
- Link to other relevant docs
- Add troubleshooting sections
- Include before/after examples

❌ DON'T:
- Over-document obvious code
- Leave commented-out code
- Write documentation nobody will read
- Assume reader knows abbreviations
- Duplicate information across files

---

## Questions & Help

### Before Asking

1. Search existing issues/PRs
2. Check documentation files
3. Review git log for similar changes
4. Test locally first

### Getting Help

1. Create GitHub issue with:
   - What you're trying to do
   - What you've already tried
   - Error messages (if any)
   - Steps to reproduce

2. For code review questions:
   - Show your branch/changes
   - Explain your approach
   - Ask specific questions

---

## Summary

Contributing guidelines:
1. ✅ Create feature branch with descriptive name
2. ✅ Make changes following code style
3. ✅ Test thoroughly before committing
4. ✅ Write clear commit messages
5. ✅ Update documentation
6. ✅ Create PR with complete description
7. ✅ Address review feedback
8. ✅ Ensure PR merged cleanly

Thanks for contributing! 🎉

---

## Additional Resources

- [Nix Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Home-Manager Manual](https://rycee.gitlab.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Git Workflow](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflow)
- [Conventional Commits](https://www.conventionalcommits.org/)
