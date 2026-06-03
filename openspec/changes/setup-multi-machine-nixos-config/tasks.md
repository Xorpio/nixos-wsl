## 1. Initialize Flake Structure

- [ ] 1.1 Create `flake.nix` with inputs: nixpkgs, home-manager, sops-nix
- [ ] 1.2 Define flake outputs structure (nixosConfigurations for each host)
- [ ] 1.3 Create initial `flake.lock` file
- [ ] 1.4 Verify flake syntax with `nix flake check`

## 2. Create Directory Structure

- [ ] 2.1 Create `hosts/` directory with subdirectories: `daf-laptop/`, `centric-laptop/`, `home-desktop/`
- [ ] 2.2 Create `modules/` directory with subdirectories: `shell/`, `neovim/`, `git/`, `dev-tools/`
- [ ] 2.3 Create `nvim-config/` directory with standard Neovim layout: `init.lua`, `plugin/`, `lua/`, `ftplugin/`
- [ ] 2.4 Create `secrets/` directory with subdirectories: `daf-laptop/`, `centric-laptop/`, `home-desktop/`
- [ ] 2.5 Create `.gitignore` entries for `*.key`, `.sops.yaml.key`, and other secret files

## 3. Set Up Shared Modules

- [ ] 3.1 Create `modules/shell/default.nix` with zsh/bash configuration
- [ ] 3.2 Create `modules/neovim/default.nix` declaring Neovim and plugins
- [ ] 3.3 Create `modules/git/default.nix` with git configuration
- [ ] 3.4 Create `modules/dev-tools/default.nix` with common development tools
- [ ] 3.5 Create `modules/sops/default.nix` with sops-nix integration

## 4. Set Up Per-Machine System Configurations

- [ ] 4.1 Create `hosts/daf-laptop/system.nix` with system-level config
- [ ] 4.2 Create `hosts/centric-laptop/system.nix` with system-level config
- [ ] 4.3 Create `hosts/home-desktop/system.nix` with system-level config
- [ ] 4.4 Create `hosts/daf-laptop/default.nix` combining system and home-manager
- [ ] 4.5 Create `hosts/centric-laptop/default.nix` combining system and home-manager
- [ ] 4.6 Create `hosts/home-desktop/default.nix` combining system and home-manager

## 5. Set Up Per-Machine Home-Manager Configurations

- [ ] 5.1 Create `hosts/daf-laptop/home.nix` importing shared modules with daf-specific overrides
- [ ] 5.2 Create `hosts/centric-laptop/home.nix` importing shared modules with centric-specific overrides
- [ ] 5.3 Create `hosts/home-desktop/home.nix` importing shared modules with home-specific overrides
- [ ] 5.4 Configure home-manager to symlink `nvim-config/` to `~/.config/nvim/` in each home.nix

## 6. Initialize Neovim Configuration

- [ ] 6.1 Create `nvim-config/init.lua` with basic Neovim initialization
- [ ] 6.2 Create `nvim-config/lua/config/` directory with modular Lua config files
- [ ] 6.3 Create `nvim-config/lua/keymaps/` directory with keymap definitions
- [ ] 6.4 Create `nvim-config/plugin/` directory for plugin-specific setup
- [ ] 6.5 Populate `modules/neovim/default.nix` with plugin declarations from nvim-config

## 7. Set Up sops-nix for Secrets

- [ ] 7.1 Generate sops public/private key pairs locally for each machine (keep .key files local only)
- [ ] 7.2 Create `.sops.yaml` configuration file with per-machine key mapping
- [ ] 7.3 Create `secrets/daf-laptop/secrets.yaml` encrypted template with sops
- [ ] 7.4 Create `secrets/centric-laptop/secrets.yaml` encrypted template with sops
- [ ] 7.5 Create `secrets/home-desktop/secrets.yaml` encrypted template with sops
- [ ] 7.6 Create `modules/sops/default.nix` integrating sops-nix into home-manager
- [ ] 7.7 Add sample encrypted secret entries to each secrets.yaml (e.g., GitHub SSH key path)
- [ ] 7.8 Verify encryption/decryption workflow: `sops secrets/daf-laptop/secrets.yaml`

## 8. Test Flake on First Machine

- [ ] 8.1 Test flake evaluation: `nix flake show --allow-import-from-derivation`
- [ ] 8.2 Test home-manager on daf-laptop: `home-manager switch --flake .#user@daf-laptop --dry-run`
- [ ] 8.3 Resolve any evaluation errors in flake.nix or modules
- [ ] 8.4 Apply home-manager to daf-laptop: `home-manager switch --flake .#user@daf-laptop`
- [ ] 8.5 Verify shell configuration applied correctly
- [ ] 8.6 Verify Neovim config symlinked to `~/.config/nvim/`
- [ ] 8.7 Verify secrets are decrypted and accessible

## 9. Test Flake on Second Machine

- [ ] 9.1 Test home-manager on centric-laptop: `home-manager switch --flake .#user@centric-laptop --dry-run`
- [ ] 9.2 Resolve any machine-specific errors
- [ ] 9.3 Apply home-manager to centric-laptop: `home-manager switch --flake .#user@centric-laptop`
- [ ] 9.4 Verify configuration applied and machines are not interfering with each other

## 10. Test Flake on Third Machine

- [ ] 10.1 Test home-manager on home-desktop: `home-manager switch --flake .#user@home-desktop --dry-run`
- [ ] 10.2 Resolve any machine-specific errors
- [ ] 10.3 Apply home-manager to home-desktop: `home-manager switch --flake .#user@home-desktop`
- [ ] 10.4 Verify all three machines have applied configurations correctly

## 11. Documentation and Final Validation

- [ ] 11.1 Create `README.md` with setup instructions for each machine
- [ ] 11.2 Document the deployment commands: `home-manager switch --flake .#user@hostname`
- [ ] 11.3 Document the secret setup process and key locations
- [ ] 11.4 Document how to add new machines or modules
- [ ] 11.5 Create `CONTRIBUTING.md` or guidelines for maintaining shared modules
- [ ] 11.6 Final validation: ensure all three machines can rebuild from current repo state
- [ ] 11.7 Commit all changes to git with meaningful commit messages
