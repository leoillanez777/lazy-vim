return {
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
        tsserver = { enabled = false },
        vtsls = { enabled = false },
        volar = {
          --filetypes = { "vue" },
          -- Agregar HTML y otros tipos de archivo que quieras que maneje Volar
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
          root_dir = require("lspconfig.util").root_pattern("vue.config.js", "vite.config.js", "nuxt.config.js"),
          autostart = function(bufnr)
            return not _G.is_angular_project(bufnr) -- Previene que Volar inicie en proyectos Angular
          end,
          init_options = {
            typescript = {
              tsdk = vim.fn.expand(
                "$HOME/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
              ),
            },
            vue = {
              hybridMode = false,
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
            documentFeatures = {
              selectionRange = true,
              foldingRange = true,
              linkedEditingRange = true,
              documentSymbol = true,
              documentColor = true,
              documentFormatting = {
                defaultPrintWidth = 100,
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
        html = {
          filetypes = { "html" },
          init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
              css = true,
              javascript = true,
            },
          },
        },
      },
    },
  },
}
