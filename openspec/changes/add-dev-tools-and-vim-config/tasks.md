## 1. Update flake.nix

- [x] 1.1 Add taskwarrior to home.packages list in flake.nix
- [x] 1.2 Add tasksh to home.packages list in flake.nix
- [x] 1.3 Add taskwarrior-tui to home.packages list in flake.nix
- [x] 1.4 Add neovim to home.packages list in flake.nix
- [x] 1.5 Enable vim in home-manager configuration (programs.vim.enable = true)
- [x] 1.6 Configure vim to enable line numbers (programs.vim.settings.number = true)

## 1b. Pre-deployment fix (Wanda Maximoff — 2026-06-04)

- [x] 1b.1 Move taskwarrior3/tasksh/taskwarrior-tui/neovim into per-machine home.nix (was only in nixosConfigurations, missing from homeConfigurations / home-manager switch path)
- [x] 1b.2 Move programs.vim config into per-machine home.nix for same reason
- [x] 1b.3 Remove dead modules.neovim (enable=false) import from home-desktop/home.nix
- [x] 1b.4 Remove now-redundant flake.nix home.packages / vim block and unused pkgs binding

## 2. Test on daf-laptop

- [ ] 2.1 Deploy changes using home-manager switch
- [ ] 2.2 Verify taskwarrior is available (run: task --version)
- [ ] 2.3 Verify tasksh is available (run: tasksh and exit)
- [ ] 2.4 Verify taskwarrior-tui is available (run: taskwarrior-tui and exit)
- [ ] 2.5 Verify neovim is available (run: nvim --version)
- [ ] 2.6 Verify vim has line numbers enabled (open a file with vim and check left margin)

## 3. Deploy to centric-laptop

- [ ] 3.1 Run: sudo nixos-rebuild switch --flake .#centric-laptop
- [ ] 3.2 Verify taskwarrior is available on centric-laptop
- [ ] 3.3 Verify taskwarrior-tui is available on centric-laptop
- [ ] 3.4 Verify neovim is available on centric-laptop
- [ ] 3.5 Verify vim has line numbers on centric-laptop

## 4. Deploy to home-desktop

- [ ] 4.1 Run: sudo nixos-rebuild switch --flake .#home-desktop
- [ ] 4.2 Verify taskwarrior is available on home-desktop
- [ ] 4.3 Verify taskwarrior-tui is available on home-desktop
- [ ] 4.4 Verify neovim is available on home-desktop
- [ ] 4.5 Verify vim has line numbers on home-desktop

## 5. Final verification

- [ ] 5.1 Confirm all three machines have identical package versions
- [x] 5.2 Commit flake.nix and flake.lock changes to git
