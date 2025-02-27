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
      opts.servers = opts.servers or {}
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
      -- Solo configuramos angularls si estamos en un proyecto Angular
      if vim.g.is_angular_project then
        -- Habilitamos angularls para proyectos Angular
        opts.servers.angularls = { enabled = false }
        -- Deshabilitamos cssls en proyectos Angular
        opts.servers.cssls = { enabled = true }
      else
        -- Configuración por defecto
        opts.servers.angularls = { enabled = false }
        opts.servers.cssls = { enabled = true }
      end
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

      if vim.g.is_angular_project then
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
