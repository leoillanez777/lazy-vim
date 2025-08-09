-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Indentation settings
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 2 -- Number of spaces tabs count for
opt.tabstop = 2 -- Number of spaces tabs count for

-- Load SQL database connections
require("config.sql-connections")
