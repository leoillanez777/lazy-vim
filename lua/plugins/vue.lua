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
      if vim.g.is_vue_project then
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "volar")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = function(_, opts)
      -- Solo configuramos volar si estamos en un proyecto Vue
      if vim.g.is_vue_project then
        opts.servers = opts.servers or {}
        opts.servers.volar = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("vite.config.ts", "vue.config.ts")(fname)
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
        }
        opts.servers.tsserver = {
          enabled = not vim.g.is_vue_project
        }
        opts.servers.vtsls = {}
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Solo añadir formatters Vue si estamos en un proyecto Vue
      if vim.g.is_vue_project then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.vue = { "prettier" }
        opts.formatters_by_ft.typescript = { "prettier" }
        opts.formatters_by_ft.javascript = { "prettier" }
      end
    end,
  }
}
