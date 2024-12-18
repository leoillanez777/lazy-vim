return {
  {
    "nvim-lualine/lualine.nvim",
    priority = 1000, -- Asegura que se cargue temprano
    lazy = false, -- Desactiva lazy loading para que se cargue al inicio
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local laststatus = vim.g.lualine_laststatus or 3
      vim.o.laststatus = laststatus
      return {
        options = {
          theme = "gruvbox",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          refresh = {
            statusline = 100,
            tabline = 100,
            winbar = 100,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            { "branch" },
            {
              "diff",
              symbols = {
                added = " ",
                modified = " ",
                removed = " ",
              },
            },
          },
          lualine_c = {
            { "filename", path = 1 },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = {
                error = " ",
                warn = " ",
                info = " ",
                hint = " ",
              },
            },
          },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      -- Forzar la actualización de lualine después de la configuración
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
        callback = function()
          require("lualine").refresh()
        end,
      })
    end,
  },
}
