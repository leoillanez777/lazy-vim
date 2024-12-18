return {
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    build = ":Codeium Auth",
    commit = "937667b2cadc7905e6b9ba18ecf84694cf227567", -- Fije version, porque da error la ultima actualizacion
    opts = {
      enable_cmp_source = vim.g.ai_cmp,
      enable_chat = true,
      virtual_text = {
        enabled = not vim.g.ai_cmp,
        key_bindings = {
          accept = false, -- handled by blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
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
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "codeium.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "codeium" },
        providers = {
          codeium = {
            kind = "Codeium",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
