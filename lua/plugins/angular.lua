return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
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
        -- Desactivar el servidor HTML para archivos Angular
        html = {
          filetypes = { "html" },
          -- Excluir archivos de Angular
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- No iniciar el servidor HTML si estamos en un proyecto Angular
            if util.root_pattern("angular.json", "project.json")(fname) then
              return nil
            end
            return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", "vite.config.js", "index.html")(
              fname
            )
          end,
        },
        angularls = { enabled = false },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "angular-language-server" })
    end,
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
}
