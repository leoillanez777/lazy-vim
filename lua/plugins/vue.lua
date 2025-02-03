-- stylua: ignore
-- if true then return {} end

return {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vue", "typescript", "javascript", "tsx", "css", "scss" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "volar")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        volar = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("vite.config.ts", "tsconfig.json")(fname)
          end,
          init_options = {
            typescript = {
              tsdk = vim.fn.expand(
                "$HOME/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
              ),
            },
            languageFeatures = {
              implementation = true,
              references = true,
              definition = true,
              typeDefinition = true,
              callHierarchy = true,
              hover = true,
              rename = true,
              renameFileRefactoring = true,
              signatureHelp = true,
              codeAction = true,
              diagnostics = true,
              semanticTokens = true,
            },
            vue = {
              hybridMode = false,
            },
          },
          on_new_config = function(new_config, new_root_dir)
            local lib_path = vim.fs.find("node_modules/typescript/lib", {
              path = new_root_dir,
              upward = true,
              type = "directory"
            })[1]
            if lib_path then
              new_config.init_options.typescript.tsdk = lib_path
            end
          end,
        },
        vtsls = {},
        -- Desactivar ts_ls para evitar conflictos con Volar
        ts_ls = {
          enabled = false,
        },
      },
    },
  },
  {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      vue = { "prettier" },
      typescript = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      javascript = { "prettier" },
    },
  },
}
}
