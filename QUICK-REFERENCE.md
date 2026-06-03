# Quick Reference Guide - Phase 6.5 & 7

## 🎯 What Was Completed

### Phase 6.5: Neovim Module
- 26+ plugins configured
- LSP, Telescope, NvimTree ready
- Full documentation included

### Phase 7: sops-nix Secrets
- 3 machines configured (daf-laptop, centric-laptop, home-desktop)
- Age encryption enabled
- Encrypted secrets templates created
- Verification tools provided

---

## 🚀 Quick Start

### View Neovim Plugins
```bash
# See what plugins are configured
cat ~/.config/nvim/PLUGINS.md

# Launch Neovim
nvim

# Use Telescope
:Telescope find_files
:Telescope live_grep
```

### Test Sops Setup
```bash
# Run verification
bash secrets/verify-sops.sh

# On your machine, set up the age key
mkdir -p ~/.config/sops/age
cp secrets/daf-laptop/.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Decrypt secrets
sops -d secrets/daf-laptop/secrets.yaml

# Edit secrets
sops secrets/daf-laptop/secrets.yaml
```

---

## 📋 Neovim Keybindings

| Binding | Action |
|---------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fh` | Help tags |
| `<leader>e` | Toggle file explorer |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Floating diagnostic |
| `<C-h/j/k/l>` | Navigate windows |

---

## 🔐 Sops Secrets Files

### Location
- **Configuration**: `.sops.yaml` ← committed to git
- **Private keys**: `secrets/{hostname}/.key` ← local only (in .gitignore)
- **Encrypted secrets**: `secrets/{hostname}/secrets.yaml` ← committed

### Contents
Each machine has secrets for:
- SSH configuration
- GitHub credentials
- Environment variables
- Machine-specific services (AWS, work APIs, media library, etc.)

---

## 🔧 Common Tasks

### Add a New Secret
```bash
# Edit encrypted secrets
sops secrets/daf-laptop/secrets.yaml

# Add under appropriate section
# Save and exit - automatically re-encrypted
```

### Create New Machine
```bash
# Generate new age key
age-keygen -o secrets/new-machine/.key

# Add public key to .sops.yaml
# Create initial secrets file
sops secrets/new-machine/secrets.yaml
```

### Deploy to Machine
```bash
# Copy key to machine
mkdir -p ~/.config/sops/age
cp secrets/daf-laptop/.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Test it works
sops -d secrets/daf-laptop/secrets.yaml

# Home-manager will handle the rest
```

---

## 📚 Documentation

- **Sops Setup**: `secrets/README.md` (comprehensive guide)
- **This Guide**: `PHASE-6-7-COMPLETION.md` (detailed summary)
- **Status**: `PHASE-6-7-STATUS.txt` (visual overview)
- **Neovim Plugins**: Auto-created at `~/.config/nvim/PLUGINS.md`
- **Sops Helper**: Auto-created at `~/.config/sops/README.md`

---

## ✅ Verification Checklist

- [ ] Neovim launches: `nvim`
- [ ] Telescope works: `:Telescope find_files`
- [ ] LSP ready: `:LspInfo`
- [ ] Sops installed: `which sops`
- [ ] Age key placed: `ls ~/.config/sops/age/keys.txt`
- [ ] Secrets decrypt: `sops -d secrets/daf-laptop/secrets.yaml`
- [ ] Verification passes: `bash secrets/verify-sops.sh`

---

## 🎓 Learning Resources

- [Neovim Docs](https://neovim.io/)
- [Telescope Guide](https://github.com/nvim-telescope/telescope.nvim)
- [Sops Documentation](https://github.com/mozilla/sops)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Home-Manager Manual](https://rycee.gitlab.io/home-manager/)

---

## 🆘 Troubleshooting

### Sops key not found
```bash
# Make sure age key is in correct location
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
chmod 600 ~/.config/sops/age/keys.txt
```

### Can't decrypt secrets
```bash
# Check age key has correct permissions
ls -la ~/.config/sops/age/keys.txt

# Try with explicit key
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d secrets/daf-laptop/secrets.yaml
```

### Neovim plugins not loading
```bash
# Check plugin status in Neovim
:PlugStatus

# Check Neovim version
nvim --version

# Check error messages
nvim -u ~/.config/nvim/init.lua 2>&1 | head -20
```

---

## 🎉 You're All Set!

All files are ready for Phase 8 testing. The flake can now be deployed to all three machines with:

```bash
# On each machine:
home-manager switch --flake .#user@hostname
```

**Happy Nix-ing! 🚀**
