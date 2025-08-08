return {
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = true,
  --   opts = { style = "storm" },
  -- },
  -- {
  --   "scottmckendry/cyberdream.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   start = true,
  --   config = function()
  --     require("cyberdream").setup({
  --       transparent = true,
  --     })
  --   end,
  -- },
  -- { "iruzo/matrix-nvim" },
  -- {
  --   "xero/miasma.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd("colorscheme miasma")
  --   end,
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
