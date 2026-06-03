-- Neovim configuration entry point
-- This file is managed by home-manager and symlinked to ~/.config/nvim/init.lua

-- Load core configuration modules
require("config.settings")
require("config.keymaps")

-- Load plugin-specific configurations from plugin/ directory
-- (They are auto-sourced by Neovim)
