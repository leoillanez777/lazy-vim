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
              -- Añadir configuraciones para retrocompatibilidad
              experimental = {
                enableIvy = false, -- Desactivar Ivy para Angular 11
                useCommonModule = true, -- Forzar uso de CommonModule
              },
              compiler = {
                strictTemplates = false, -- Desactivar templates estrictos para mayor compatibilidad
                enableResourceInlining = false,
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
              -- Reducir nivel de diagnóstico para suprimir algunos errores
              diagnostics = {
                enableWithoutWorkspace = false,
                level = "warning",
              },
              preferences = {
                includeCompletionsWithSnippetText = true,
                includeAutomaticOptionalChainCompletions = true,
                quotePreference = "single",
                importModuleSpecifierPreference = "relative",
              },
            },
          },
          on_new_config = function(new_config, new_root_dir)
            -- Definir la ruta base de Mason
            local mason_path = vim.fn.expand("$HOME/.local/share/nvim/mason/packages/angular-language-server")

            -- Rutas para TypeScript y Angular
            local path_ts = mason_path .. "/node_modules/typescript/lib"
            local path_ng = mason_path .. "/node_modules/@angular/language-server"
            local ngserver_path = mason_path .. "/node_modules/@angular/language-server/bin/ngserver"

            -- Verificar si las rutas existen
            if vim.fn.executable(ngserver_path) == 1 then
              new_config.cmd = {
                ngserver_path,
                "--stdio",
                "--tsProbeLocations",
                path_ts,
                "--ngProbeLocations",
                path_ng,
              }
            else
              -- Intentar usar el comando global si no se encuentra en Mason
              new_config.cmd = {
                "ngserver",
                "--stdio",
                "--tsProbeLocations",
                path_ts,
                "--ngProbeLocations",
                path_ng,
              }

              -- Notificar al usuario si no se encuentra ngserver
              if vim.fn.executable("ngserver") == 0 then
                vim.notify(
                  "ngserver no encontrado. Asegúrate de tener @angular/language-server instalado globalmente o en Mason",
                  vim.log.levels.WARN
                )
              end
            end

            -- -- Buscar tsconfig.json en el directorio del proyecto
            -- local tsconfig = vim.fs.find("tsconfig.json", {
            --   upward = true,
            --   path = new_root_dir,
            -- })[1]
            --
            -- if tsconfig then
            --   -- Añadir la ubicación del tsconfig si existe
            --   table.insert(new_config.cmd, "--tsconfig")
            --   table.insert(new_config.cmd, tsconfig)
            -- end
          end,
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

            local opts = { buffer = bufnr }
            vim.keymap.set("n", "gd", function()
              require("telescope.builtin").lsp_definitions({ reuse_win = true })
            end, vim.tbl_extend("force", opts, { desc = "Goto Definition" }))
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
