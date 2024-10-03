return {
  "nvim-cmp",
  dependencies = {
    -- codeium
    {
      "Exafunction/codeium.nvim",
      event = "BufEnter",
      cmd = "Codeium",
      build = ":Codeium Auth",
      commit = "937667b2cadc7905e6b9ba18ecf84694cf227567", -- Fije version, porque da error la ultima actualizacion
      opts = {
        enable_chat = true,
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      event = "VeryLazy",
      opts = function(_, opts)
        table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))
      end,
    },
  },
  --@params opts cmp.ConfigSchema
  opts = function(_, opts)
    table.insert(opts.sources, 1, {
      name = "codeium",
      group_index = 1,
      priority = 100,
    })
  end,
}
