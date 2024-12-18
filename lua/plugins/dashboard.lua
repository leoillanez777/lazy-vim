return {
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
  {
    "nvimdev/dashboard-nvim",
    lazy = false,
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          week_header = {
            enable = true,
            concat = "Leonardo Illanez",
          },
          shortcut = {
            { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
            {
              icon = " ",
              icon_hl = "@variable",
              desc = "Files",
              group = "Label",
              action = "Telescope find_files",
              key = "f",
            },
            {
              icon = "󰋗 ",
              desc = "Help",
              group = "DiagnosticHint",
              action = "Telescope help_tags",
              key = "h",
            },
            {
              icon = " ",
              desc = "Mason",
              group = "Number",
              action = "Mason",
              key = "m",
            },
          },
          packages = { enable = true },
          project = {
            enable = true,
            limit = 8,
            icon = " ",
            label = "Projects",
            action = "Telescope find_files cwd=",
          },
          mru = {
            enable = true,
            limit = 8,
            icon = " ",
            label = "Recent Files",
          },
          footer = {
            " ",
            " Github: https://github.com/LeonardoIllanez",
            "Made with  by Leonardo Illanez",
          },
        },
      })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-telescope/telescope.nvim" },
  },
}
