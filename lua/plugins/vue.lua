return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vue", "typescript", "javascript", "css", "scss", "html", "json" } },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "vue-language-server",
        "typescript-language-server",
        "prettier",
        "eslint_d",
      })
    end,
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
    init = function()
      -- Desactivar autodetección de filetypes para angular en archivos .vue
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.vue",
        callback = function()
          vim.bo.filetype = "vue"
          -- Detener el servidor angular si está activo
          local clients = vim.lsp.get_clients()
          for _, client in ipairs(clients) do
            print("client name", client.name)
            if client.name == "angularls" then
              vim.lsp.stop_client(client.id)
            end
          end
        end,
      })
    end,
    opts = {
      servers = {
        tsserver = { enabled = false },
        vtsls = { enabled = false },
        volar = {
          filetypes = { "vue" },
          root_dir = require("lspconfig.util").root_pattern("vue.config.js", "vite.config.js", "nuxt.config.js"),
          init_options = {
            typescript = {
              tsdk = vim.fn.expand(
                "$HOME/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
              ),
            },
            vue = {
              hybridMode = true,
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
              workspaceSymbol = true,
              diagnostics = true,
              semanticTokens = true,
              completion = {
                defaultTagNameCase = "both",
                defaultAttrNameCase = "kebabCase",
              },
            },
          },
          on_new_config = function(new_config, new_root_dir)
            local lib_path = vim.fs.find("node_modules/typescript/lib", { path = new_root_dir, upward = true })[1]
            if lib_path then
              new_config.init_options.typescript.tsdk = lib_path
            end
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        vue = { "prettier" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        vue = { "eslint" },
      },
    },
  },
}
