return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- The repo is windsurf.nvim but its Lua module is still "codeium",
    -- so we point lazy.nvim at the right module to pass opts correctly.
    main = "codeium",
    opts = {
      enable_cmp_source = vim.g.ai_cmp,
      enable_chat = true,
      virtual_text = {
        enabled = not vim.g.ai_cmp,
        key_bindings = {
          accept = false, -- handled by nvim-cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      "Exafunction/windsurf.nvim",
      "onsails/lspkind.nvim",
    },
    opts = function(_, opts)
      -- Register the Codeium completion source (windsurf.nvim exposes it as "codeium").
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "codeium", group_index = 1, priority = 100 })

      -- Format entries with lspkind, mapping the Codeium icon.
      opts.formatting = opts.formatting or {}
      opts.formatting.format = require("lspkind").cmp_format({
        mode = "symbol",
        maxwidth = 50,
        ellipsis_char = "...",
        symbol_map = { Codeium = "" },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))
    end,
  },
}
