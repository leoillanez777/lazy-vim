return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss", "html", "typescript" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.template.html", "*.container.html" },
        callback = function()
          vim.bo.filetype = "htmlangular"
          vim.treesitter.start(nil, "angular")
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = { enabled = false },
        vtsls = { enabled = false },
        angularls = {
          root_dir = require("lspconfig").util.root_pattern("angular.json", "project.json"),
          filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
          settings = {
            angular = {
              exclude = { "**/**.vue" },
              analytics = {
                enable = false,
              },
              trace = {
                server = "verbose",
              },
              featureFlags = {
                completions = true,
                diagnostics = {
                  enable = true,
                  enableWithoutWorkspace = true,
                },
                documentHighlight = true,
                documentSymbol = true,
                hover = true,
                navigation = true,
                rename = true,
                signatureHelp = true,
                formatting = true,
                goToDefinition = true,
                references = true,
                implementationCodeLens = true,
              },
              preferences = {
                includeCompletionsWithSnippetText = true,
                includeAutomaticOptionalChainCompletions = true,
                quotePreference = "single",
                importModuleSpecifierPreference = "relative",
              },
              compiler = {
                -- Mejorar el análisis de templates
                strictTemplates = true,
                enableResourceInlining = true,
              },
            },
          },
        },
      },
      setup = {
        angularls = function()
          -- Asegurarnos de que el servidor se inicie para archivos HTML de Angular
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "html", "htmlangular" },
            callback = function()
              -- Verificar si estamos en un proyecto Angular
              local root_dir =
                require("lspconfig").util.root_pattern("angular.json", "project.json")(vim.fn.expand("%:p"))
              if root_dir then
                vim.bo.filetype = "htmlangular"
              end
            end,
          })

          LazyVim.lsp.on_attach(function(client, bufnr)
            --HACK: disable angular renaming capability due to duplicate rename popping up
            client.server_capabilities.renameProvider = false

            -- Configurar keymaps específicos de Angular
            local map = function(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Navegación
            map("n", "gd", vim.lsp.buf.definition, "Ir a definición")
            map("n", "gr", vim.lsp.buf.references, "Mostrar referencias")
            map("n", "gi", vim.lsp.buf.implementation, "Ir a implementación")
            map("n", "gt", vim.lsp.buf.type_definition, "Ir a definición de tipo")

            -- Acciones de código
            map("n", "<leader>ca", vim.lsp.buf.code_action, "Acciones de código")
            map("n", "<leader>cr", vim.lsp.buf.rename, "Renombrar")
            map("n", "<leader>cf", function()
              vim.lsp.buf.format({ async = true })
            end, "Formatear documento")

            -- Información
            map("n", "K", vim.lsp.buf.hover, "Mostrar documentación")
            map("n", "<C-k>", vim.lsp.buf.signature_help, "Mostrar firma")

            -- Diagnósticos
            map("n", "<leader>cd", vim.diagnostic.open_float, "Mostrar diagnóstico")
            map("n", "[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
            map("n", "]d", vim.diagnostic.goto_next, "Siguiente diagnóstico")

            -- Características específicas de Angular
            map("n", "<leader>aT", "<cmd>Angular.GoToTemplateForComponent<CR>", "Ir a template")
            map("n", "<leader>aC", "<cmd>Angular.GoToComponentFromTemplate<CR>", "Ir a componente")
            map("n", "<leader>aS", "<cmd>Angular.SwitchTemplateOrComponent<CR>", "Cambiar entre template/componente")
          end, "angularls")
        end,
      },
    },
  },
  {
    "conform.nvim",
    opts = function(_, opts)
      if LazyVim.has_extra("formatting.prettier") then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.htmlangular = { "prettier" }
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "angular-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
    end,
  },
}
