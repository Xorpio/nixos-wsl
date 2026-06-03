# Wanda Maximoff — Project History

## Context (Day 1)

**Owner:** Niek de Gooijer  
**Project:** nixos-wsl — Multi-machine reproducible NixOS configuration  
**Goal:** Centralize configuration for three WSL instances (Daf work laptop, Centric work laptop, home desktop) using Nix flakes, home-manager, and sops-nix.

**Architecture Decisions (from Tony):**
- home-manager as primary deployment tool (day-to-day updates)
- Separate `nvim-config/` directory with Lua files + `modules/neovim/` for Nix package management
- Shared configuration symlinked to ~/.config/nvim/ on each machine
- Per-machine overrides in machine-specific home.nix files

**Key Work:**
- Task 5: Integrate neovim config with home-manager (symlinks)
- Task 6: Initialize `nvim-config/` with Lua structure
- Task 7: Create `modules/neovim/default.nix` declaring plugins
- Machine-specific home.nix files with module composition

**Neovim Config Location:**
```
nvim-config/
├── init.lua
├── plugin/
├── lua/
│   ├── config/
│   └── keymaps/
└── ftplugin/
```

## Learnings

(None yet — awaiting implementation)
