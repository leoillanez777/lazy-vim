return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      if vim.g.is_react_project then
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "tsserver")
        table.insert(opts.ensure_installed, "eslint")
        table.insert(opts.ensure_installed, "tailwindcss")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = function(_, opts)
      -- Solo configuramos para proyectos React
      if vim.g.is_react_project then
        opts.servers = opts.servers or {}

        -- TypeScript/JavaScript server con timeout aumentado
        opts.servers.tsserver = {
          timeout_ms = 15000,
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "jsx", "tsx" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
          end,
          init_options = {
            preferences = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              suggest = {
                includeCompletionsForModuleExports = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              suggest = {
                includeCompletionsForModuleExports = true,
              },
            },
            completions = {
              completeFunctionCalls = true,
            },
          },
          on_new_config = function(new_config, new_root_dir)
            -- Buscar TypeScript local del proyecto
            local lib_path = vim.fs.find("node_modules/typescript/lib", {
              path = new_root_dir,
              upward = true,
              type = "directory",
            })[1]
            if lib_path then
              new_config.init_options = new_config.init_options or {}
              new_config.init_options.typescript = new_config.init_options.typescript or {}
              new_config.init_options.typescript.tsdk = lib_path
            end
          end,
        }

        -- ESLint configuration
        opts.servers.eslint = {
          timeout_ms = 10000,
          settings = {
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = "separateLine",
              },
              showDocumentation = {
                enable = true,
              },
            },
            codeActionOnSave = {
              enable = false,
              mode = "all",
            },
            format = false,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            quiet = false,
            rulesCustomizations = {},
            run = "onType",
            useESLintClass = false,
            validate = "on",
            workingDirectory = {
              mode = "location",
            },
          },
        }

        -- TailwindCSS si está presente
        opts.servers.tailwindcss = {
          timeout_ms = 10000,
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
              validate = true,
            },
          },
        }

        -- Deshabilitar volar y vtsls para proyectos React
        opts.servers.volar = { enabled = false }
        opts.servers.vtsls = { enabled = false }
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Solo añadir formatters React si estamos en un proyecto React
      if vim.g.is_react_project then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.javascript = { "prettier" }
        opts.formatters_by_ft.javascriptreact = { "prettier" }
        opts.formatters_by_ft.typescript = { "prettier" }
        opts.formatters_by_ft.typescriptreact = { "prettier" }
        opts.formatters_by_ft.jsx = { "prettier" }
        opts.formatters_by_ft.tsx = { "prettier" }
        opts.formatters_by_ft.css = { "prettier" }
        opts.formatters_by_ft.scss = { "prettier" }
        opts.formatters_by_ft.html = { "prettier" }
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if vim.g.is_react_project then
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, {
          "typescript-language-server",
          "eslint-lsp",
          "prettier",
          "tailwindcss-language-server",
        })
      end
    end,
  },
}
