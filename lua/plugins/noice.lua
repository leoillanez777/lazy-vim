return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.cmdline = opts.cmdline or {}
    opts.cmdline.format = opts.cmdline.format or {}
    opts.cmdline.format.cmdline = { pattern = "^:", icon = "" }
    return opts
  end,
}
