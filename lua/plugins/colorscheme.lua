return {
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = true,
  --   opts = { style = "storm" },
  -- },
  { "ellisonleao/gruvbox.nvim" },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
      transparent_mode = true,
    },
  },
  { "xiyaowong/transparent.nvim" },
}
