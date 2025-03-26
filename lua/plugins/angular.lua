return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end

      if vim.g.is_angular_project then
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
          pattern = { "*.component.html", "*.container.html" },
          callback = function()
            vim.bo.filetype = "htmlangular"
            vim.treesitter.start(nil, "angular")
          end,
        })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ts_framework = require("config.typescript-framework")
      opts.servers = opts.servers or {}

      -- Configure HTML server with proper exclusions for Angular
      opts.servers.html = {
        filetypes = { "html" },
        root_dir = function(fname)
          local util = require("lspconfig.util")

          -- No iniciar el servidor HTML si estamos en un proyecto Angular
          if vim.g.is_angular_project and util.root_pattern("angular.json", "project.json")(fname) then
            return nil
          end

          return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", "vite.config.js", "index.html")(
            fname
          )
        end,
      }

      -- Only configure Angular LSP if in Angular project and should use Angular LSP
      if vim.g.is_angular_project and ts_framework.should_use_angular_lsp() then
        -- Define proper root directory criteria for angularls
        opts.servers.angularls = {
          filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("angular.json", "project.json")(fname)
          end,
          -- Ensure Angular knows where to find TypeScript
          init_options = {
            codeAnalysis = {
              updateImportsOnFileMove = {
                enabled = "always",
              },
            },
            suggest = {
              includeCompletionsForImportStatements = true,
            },
          },
          -- Set proper cmd with TypeScript paths
          on_new_config = function(new_config, new_root_dir)
            local project_root = new_root_dir
            -- Find typescript in node_modules
            local ts_path = vim.fn.finddir("node_modules/typescript", project_root .. ";")
            if ts_path == "" then
              ts_path = vim.fn.expand("$HOME/.local/share/nvim/mason/packages/angular-language-server/node_modules")
            else
              ts_path = project_root .. "/" .. ts_path:gsub("typescript$", "")
            end

            new_config.cmd = {
              "ngserver",
              "--stdio",
              "--tsProbeLocations",
              ts_path .. "," .. project_root .. "/node_modules",
              "--ngProbeLocations",
              vim.fn.expand(
                "$HOME/.local/share/nvim/mason/packages/angular-language-server/node_modules/@angular/language-server/node_modules"
              )
                .. ","
                .. project_root
                .. "/node_modules",
            }
          end,
        }

        -- Disable vtsls for modern Angular projects
        opts.servers.vtsls = { enabled = false }
        opts.servers.tsserver = { enabled = false }
        opts.servers.ts_ls = { enabled = false }
      elseif vim.g.is_angular_project then
        -- For legacy Angular, use vtsls and disable angularls
        opts.servers.vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("angular.json", "project.json", "tsconfig.json", "jsconfig.json")(fname)
          end,
          -- Configure vtsls to use project TypeScript version
          on_new_config = function(new_config, new_root_dir)
            local project_root = new_root_dir
            -- Find typescript in node_modules
            local ts_path = vim.fn.finddir("node_modules/typescript", project_root .. ";")
            if ts_path ~= "" then
              new_config.init_options = new_config.init_options or {}
              new_config.init_options.typescript = new_config.init_options.typescript or {}
              new_config.init_options.typescript.tsdk = project_root .. "/" .. ts_path .. "/lib"
              new_config.init_options.typescript.diagnostics = { enable = true }
            else
              vim.notify("vtsls: TypeScript not found in node_modules, using bundled version", vim.log.levels.WARN)
            end
          end,
        }

        -- Disable angularls and tsserver for legacy Angular
        opts.servers.angularls = { enabled = false }
        opts.servers.tsserver = { enabled = false }
        opts.servers.ts_ls = { enabled = false }
      else
        -- Not an Angular project - determine if we should use vtsls based on TypeScript version
        if ts_framework.is_legacy_typescript() then
          -- Legacy TypeScript, use vtsls
          opts.servers.vtsls = {
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
            on_new_config = function(new_config, new_root_dir)
              local project_root = new_root_dir
              -- Find typescript in node_modules
              local ts_path = vim.fn.finddir("node_modules/typescript", project_root .. ";")
              if ts_path ~= "" then
                new_config.init_options = new_config.init_options or {}
                new_config.init_options.typescript = new_config.init_options.typescript or {}
                new_config.init_options.typescript.tsdk = project_root .. "/" .. ts_path .. "/lib"
                vim.notify(
                  "vtsls: Using TypeScript from " .. new_config.init_options.typescript.tsdk,
                  vim.log.levels.INFO
                )
              else
                vim.notify("vtsls: TypeScript not found in node_modules, using bundled version", vim.log.levels.WARN)
              end
            end,
          }
          opts.servers.tsserver = { enabled = false }
          opts.servers.ts_ls = { enabled = false }
        else
          -- Modern TypeScript, use tsserver
          opts.servers.ts_ls = {}
          opts.servers.vtsls = { enabled = false }
        end
        -- Disable angularls for non-Angular projects
        opts.servers.angularls = { enabled = false }
      end

      -- Always enable CSS for any project type
      opts.servers.cssls = { enabled = true }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "prettier",
        "css-lsp",
      })

      -- Check if we should install angular-language-server
      local ts_framework = require("config.typescript-framework")
      if vim.g.is_angular_project and ts_framework.should_use_angular_lsp() then
        table.insert(opts.ensure_installed, "angular-language-server")
      end
    end,
  },
  {
    "conform.nvim",
    opts = function(_, opts)
      if vim.g.is_angular_project and LazyVim.has_extra("formatting.prettier") then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.htmlangular = { "prettier" }
        opts.formatters_by_ft.scss = { "prettier", "prettierd" }
        opts.formatters_by_ft.css = { "prettier", "prettierd" }
      end
    end,
  },
}
