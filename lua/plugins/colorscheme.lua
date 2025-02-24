return {
   {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon",
        light_style = "day", -- The theme is used when the background is set to light
        day_brightness = 0.3,
        dim_inactive = false,
        lualine_bold = false,
        cache = true,
        -- Puedes ajustar otras opciones aquí según tus preferencias
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },

        ---@param colors ColorScheme
        ---@diagnostic disable-next-line: unused-local
        on_colors = function(colors) end,

        ---@param highlights tokyonight.Highlights
        ---@param colors ColorScheme
        on_highlights = function(highlights, colors) end,

        ---@type table<string, boolean|{enabled:boolean}>
        plugins = {
          -- enable all plugins when not using lazy.nvim
          -- set to false to manually enable/disable plugins
          all = package.loaded.lazy == nil,
          -- uses your plugin manager to automatically enable needed plugins
          -- currently only lazy.nvim is supported
          auto = true,
          -- add any plugins here that you want to enable
          -- for all possible plugins, see:
          --   * https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
          -- telescope = true,
        },
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },

  --{ "ellisonleao/gruvbox.nvim" },
  -- Configure LazyVim to load themes
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "tokyonight",
  --   },
  -- },
}
