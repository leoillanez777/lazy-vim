-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.laststatus = 3 -- Always show statusline
vim.opt.showmode = false -- Don't show mode since we have it in statusline
vim.opt.termguicolors = true -- Enable 24-bit RGB colors

-- Indentation settings
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.softtabstop = 2 -- Number of spaces that a <Tab> counts for while editing
vim.opt.smartindent = true -- Insert indents automatically
