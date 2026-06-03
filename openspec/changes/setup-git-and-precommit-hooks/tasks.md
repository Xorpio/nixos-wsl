## 1. Create .gitattributes file

- [x] 1.1 Create `.gitattributes` at repository root
- [x] 1.2 Configure LF line endings for Nix files (*.nix)
- [x] 1.3 Configure LF line endings for shell scripts (*.sh)
- [x] 1.4 Configure LF line endings for YAML files (*.yaml, *.yml)
- [x] 1.5 Configure LF line endings for JSON files (*.json)
- [x] 1.6 Configure LF line endings for Markdown files (*.md)
- [x] 1.7 Configure binary file diff handling (*.png, *.jpg, *.gif, *.zip, *.tar, *.gz)
- [x] 1.8 Configure merge=union for .squad/decisions.md
- [x] 1.9 Configure merge=union for .squad/agents/*/history.md
- [x] 1.10 Configure merge=union for .squad/log/** and .squad/orchestration-log/**
- [x] 1.11 Test .gitattributes: verify line endings on a test file commit

## 2. Create .editorconfig file

- [x] 2.1 Create `.editorconfig` at repository root
- [x] 2.2 Configure root settings: charset = utf-8, end_of_line = lf
- [x] 2.3 Configure default indentation: indent_style = space, indent_size = 2
- [x] 2.4 Configure trim_trailing_whitespace = true for all files
- [x] 2.5 Configure Makefile rules: indent_style = tab (exceptions)
- [x] 2.6 Configure shell script rules: indent_size = 2
- [x] 2.7 Configure YAML/JSON rules: indent_size = 2
- [x] 2.8 Configure Nix file rules: indent_size = 2
- [x] 2.9 Test .editorconfig: open files in multiple editors and verify indentation

## 3. Create .gitignore file

- [x] 3.1 Create `.gitignore` at repository root
- [x] 3.2 Add macOS patterns (.DS_Store, .AppleDouble, ._*, etc.)
- [x] 3.3 Add Windows patterns (Thumbs.db, desktop.ini, etc.)
- [x] 3.4 Add editor patterns (.vscode/, .idea/, *.swp, *.swo, etc.)
- [x] 3.5 Add build artifacts (*.o, *.obj, *.so, *.dll, build/, dist/, target/)
- [x] 3.6 Add Nix build output patterns (result, result-*)
- [x] 3.7 Add Node/npm patterns (node_modules/, package-lock.json comments)
- [x] 3.8 Add sops-nix key patterns (.sops*.key)
- [x] 3.9 Add environment file patterns (.env, .env.local, .env.*.local)
- [x] 3.10 Add SSH/credential patterns (id_rsa, id_dsa, id_ed25519, *.pem)
- [x] 3.11 Test .gitignore: verify patterns work with `git check-ignore`

## 4. Set up pre-commit framework

- [x] 4.1 Create `.pre-commit-config.yaml` at repository root
- [x] 4.2 Configure YAML validation hook (yamllint or equivalent)
- [x] 4.3 Configure JSON validation hook (python json.tool or equivalent)
- [x] 4.4 Configure shell script linting hook (shellcheck)
- [x] 4.5 Configure Markdown linting hook (markdownlint)
- [x] 4.6 Configure trailing whitespace check hook
- [x] 4.7 Configure end-of-file fixer hook
- [x] 4.8 Configure secret detection hook (detect-secrets)
- [x] 4.9 Configure file size limit hook (warn on large files)
- [x] 4.10 Test .pre-commit-config.yaml: run `pre-commit run --all-files` on repo

## 5. Test pre-commit installation

- [x] 5.1 Install pre-commit locally: `pip install pre-commit`
- [x] 5.2 Install Git hooks: `pre-commit install`
- [x] 5.3 Verify hooks are installed in `.git/hooks/pre-commit`
- [x] 5.4 Make a test commit with a trailing whitespace file (should fail)
- [x] 5.5 Fix the file and verify commit succeeds
- [x] 5.6 Test hook bypass with `git commit --no-verify`
- [x] 5.7 Verify hooks can be run manually: `pre-commit run --all-files`

## 6. Update .gitattributes merge driver configuration

- [x] 6.1 Verify union merge driver is available in Git
- [x] 6.2 Test merge conflict resolution on .squad/decisions.md
- [x] 6.3 Verify union merge combines both branches' additions

## 7. Update documentation

- [x] 7.1 Add "Local Development Setup" section to README
- [x] 7.2 Document pre-commit installation: `pip install pre-commit` → `pre-commit install`
- [x] 7.3 Document what pre-commit hooks do and why they're recommended
- [x] 7.4 Document how to bypass hooks if needed: `git commit --no-verify`
- [x] 7.5 Document how to run hooks manually: `pre-commit run --all-files`
- [x] 7.6 Add troubleshooting section (e.g., "hooks fail on my machine")
- [x] 7.7 Document .editorconfig support by editors (VS Code, Neovim, etc.)
- [x] 7.8 Add note about line ending normalization and potential conflicts on Windows

## 8. Optional: Integrate pre-commit with home-manager (per-machine)

- [ ] 8.1 Document optional home-manager integration for auto-installing pre-commit
- [ ] 8.2 Create optional Nix module for pre-commit (if desired for future machines)
- [ ] 8.3 Document how to enable pre-commit in home-manager config

## 9. Final validation

- [ ] 9.1 Clone repo on a fresh machine and verify `.gitattributes`, `.editorconfig`, `.gitignore` are present
- [ ] 9.2 Verify pre-commit can be installed and hooks can be run
- [ ] 9.3 Verify line endings are correct for all file types
- [ ] 9.4 Test on WSL: verify LF vs CRLF handling works correctly
- [ ] 9.5 Test on native Windows: verify no spurious line ending changes
- [ ] 9.6 Verify all team members can run `pre-commit install` successfully
- [x] 9.7 Commit all files to main branch
