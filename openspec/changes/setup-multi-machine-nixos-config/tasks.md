## 1. Initialize Flake Structure

- [x] 1.1 Create `flake.nix` with inputs: nixpkgs, home-manager, sops-nix
- [x] 1.2 Define flake outputs structure (nixosConfigurations for each host)
- [x] 1.3 Create initial `flake.lock` file
- [x] 1.4 Verify flake syntax with `nix flake check`

## 2. Create Directory Structure

- [x] 2.1 Create `hosts/` directory with subdirectories: `daf-laptop/`, `centric-laptop/`, `home-desktop/`
- [x] 2.2 Create `modules/` directory with subdirectories: `shell/`, `neovim/`, `git/`, `dev-tools/`
- [x] 2.3 Create `nvim-config/` directory with standard Neovim layout: `init.lua`, `plugin/`, `lua/`, `ftplugin/`
- [x] 2.4 Create `secrets/` directory with subdirectories: `daf-laptop/`, `centric-laptop/`, `home-desktop/`
- [x] 2.5 Create `.gitignore` entries for `*.key`, `.sops.yaml.key`, and other secret files

## 3. Set Up Shared Modules

- [x] 3.1 Create `modules/shell/default.nix` with zsh/bash configuration
- [x] 3.2 Create `modules/neovim/default.nix` declaring Neovim and plugins
- [x] 3.3 Create `modules/git/default.nix` with git configuration
- [x] 3.4 Create `modules/dev-tools/default.nix` with common development tools
- [x] 3.5 Create `modules/sops/default.nix` with sops-nix integration

## 4. Set Up Per-Machine System Configurations
- [x] 4.1 Create `hosts/daf-laptop/system.nix` with system-level config
- [x] 4.2 Create `hosts/centric-laptop/system.nix` with system-level config
- [x] 4.3 Create `hosts/home-desktop/system.nix` with system-level config
- [x] 4.4 Create `hosts/daf-laptop/default.nix` combining system and home-manager
- [x] 4.5 Create `hosts/centric-laptop/default.nix` combining system and home-manager
- [x] 4.6 Create `hosts/home-desktop/default.nix` combining system and home-manager

## 5. Set Up Per-Machine Home-Manager Configurations
- [x] 5.1 Create `hosts/daf-laptop/home.nix` importing shared modules with daf-specific overrides
- [x] 5.2 Create `hosts/centric-laptop/home.nix` importing shared modules with centric-specific overrides
- [x] 5.3 Create `hosts/home-desktop/home.nix` importing shared modules with home-specific overrides
- [x] 5.4 Configure home-manager to symlink `nvim-config/` to `~/.config/nvim/` in each home.nix

## 6. Initialize Neovim Configuration

- [x] 6.1 Create `nvim-config/init.lua` with basic Neovim initialization
- [x] 6.2 Create `nvim-config/lua/config/` directory with modular Lua config files
- [x] 6.3 Create `nvim-config/lua/keymaps/` directory with keymap definitions
- [x] 6.4 Create `nvim-config/plugin/` directory for plugin-specific setup
- [x] 6.5 Populate `modules/neovim/default.nix` with plugin declarations from nvim-config

## 7. Set Up sops-nix for Secrets

- [x] 7.1 Generate sops public/private key pairs locally for each machine (keep .key files local only)
- [x] 7.2 Create `.sops.yaml` configuration file with per-machine key mapping
- [x] 7.3 Create `secrets/daf-laptop/secrets.yaml` encrypted template with sops
- [x] 7.4 Create `secrets/centric-laptop/secrets.yaml` encrypted template with sops
- [x] 7.5 Create `secrets/home-desktop/secrets.yaml` encrypted template with sops
- [x] 7.6 Create `modules/sops/default.nix` integrating sops-nix into home-manager
- [x] 7.7 Add sample encrypted secret entries to each secrets.yaml (e.g., GitHub SSH key path)
- [x] 7.8 Verify encryption/decryption workflow: `sops secrets/daf-laptop/secrets.yaml`

## 8. Test Flake on First Machine

- [x] 8.1 Test flake evaluation: `nix flake show --allow-import-from-derivation`
- [x] 8.2 Test home-manager on daf-laptop: `home-manager switch --flake .#user@daf-laptop --dry-run`
- [x] 8.3 Resolve any evaluation errors in flake.nix or modules
- [x] 8.4 Apply home-manager to daf-laptop: `home-manager switch --flake .#user@daf-laptop`
- [x] 8.5 Verify shell configuration applied correctly
- [x] 8.6 Verify Neovim config symlinked to `~/.config/nvim/`
- [x] 8.7 Verify secrets are decrypted and accessible

## 9. Test Flake on Second Machine

- [x] 9.1 Test home-manager on centric-laptop: `home-manager switch --flake .#user@centric-laptop --dry-run`
- [x] 9.2 Resolve any machine-specific errors
- [x] 9.3 Apply home-manager to centric-laptop: `home-manager switch --flake .#user@centric-laptop`
- [x] 9.4 Verify configuration applied and machines are not interfering with each other

## 10. Test Flake on Third Machine

- [x] 10.1 Test home-manager on home-desktop: `home-manager switch --flake .#user@home-desktop --dry-run`
- [x] 10.2 Resolve any machine-specific errors
- [x] 10.3 Apply home-manager to home-desktop: `home-manager switch --flake .#user@home-desktop`
- [x] 10.4 Verify all three machines have applied configurations correctly

## 11. Documentation and Final Validation

- [x] 11.1 Create `README.md` with setup instructions for each machine
- [x] 11.2 Document the deployment commands: `home-manager switch --flake .#user@hostname`
- [x] 11.3 Document the secret setup process and key locations
- [x] 11.4 Document how to add new machines or modules
- [x] 11.5 Create `CONTRIBUTING.md` or guidelines for maintaining shared modules
- [x] 11.6 Final validation: ensure all three machines can rebuild from current repo state
- [x] 11.7 Commit all changes to git with meaningful commit messages
