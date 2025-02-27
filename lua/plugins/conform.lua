return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    opts = {
      -- Configuración de formatters por tipo de archivo
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        scss = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        handlebars = { "prettier" },
      },
      -- Configuración específica de formatters
      formatters = {
        injected = { options = { ignore_errors = true } },
        prettier = {
          condition = function(ctx)
            -- Solo usar prettier si encontramos un archivo de configuración
            return vim.fs.find({ ".prettierrc", ".prettierrc.js", ".prettierrc.json", "prettier.config.js" }, {
              upward = true,
              path = ctx.filename,
            })[1]
          end,
        },
        csharpier = {
          command = "dotnet-csharpier",
          args = { "--write-stdout" },
        },
      },
    },
  },
}
