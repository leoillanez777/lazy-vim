-- Command-line completion for nvim-cmp (blink.cmp had this enabled in LazyVim 15.x,
-- but the coding.nvim-cmp extra does not configure it).
return {
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "hrsh7th/cmp-cmdline" },
    opts = function(_, _)
      local cmp = require("cmp")

      -- Search with `/` and `?`: complete words from the current buffer.
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Command mode `:`: complete paths first, then Vim/Ex commands.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
}
