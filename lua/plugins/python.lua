return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "python", "ninja", "rst" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                extraPaths = { "/opt/homebrew/lib/python3.11/site-packages" },
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                diagnosticSeverityOverrides = {
                  reportInvalidTypeForm = "none",
                  reportOptionalSubscript = "none",
                  reportOptionalMemberAccess = "none",
                },
              },
            },
          },
        },
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              function()
                return require("lazyvim.util").lsp.action["source.organizeImports"]()
              end,
              desc = "Organize Imports",
            },
          },
        },
        ruff_lsp = {
          keys = {
            {
              "<leader>co",
              function()
                return require("lazyvim.util").lsp.action["source.organizeImports"]()
              end,
              desc = "Organize Imports",
            },
          },
        },
      },
      setup = {
        ["ruff"] = function()
          require("lazyvim.util").lsp.on_attach(function(client, bufnr)
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false

            -- Ensure code actions are enabled for Ruff
            client.server_capabilities.codeActionProvider = true

            -- Add dedicated keymapping for Ruff code actions
            vim.keymap.set("n", "<leader>cfR", function()
              vim.lsp.buf.code_action({
                filter = function(action)
                  return action.title:find("ruff") ~= nil
                end,
                apply = true,
              })
            end, { buffer = bufnr, desc = "Ruff Code Action" })
          end)
        end,
        ["pyright"] = function(_, _)
          require("lazyvim.util").lsp.on_attach(function(client, bufnr)
            -- Ensure hover is enabled for Pyright
            client.server_capabilities.hoverProvider = true

            -- Map specific pyright code actions
            vim.keymap.set("n", "<leader>cfP", function()
              vim.lsp.buf.code_action({
                filter = function(action)
                  return action.title:find("pyright") ~= nil
                end,
                apply = true,
              })
            end, { buffer = bufnr, desc = "Pyright Code Action" })
          end)
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Determinamos qué LSP utilizar basado en la variable global (o pyright por defecto)
      local python_lsp = vim.g.lazyvim_python_lsp or "pyright"
      local ruff_impl = vim.g.lazyvim_python_ruff or "ruff"

      -- Activamos los servidores adecuados
      local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp" }
      for _, server in ipairs(servers) do
        opts.servers[server] = opts.servers[server] or {}
        opts.servers[server].enabled = (server == python_lsp) or (server == ruff_impl)
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    -- stylua: ignore
    keys = {
      { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
      { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
    },
    config = function()
      -- Comprobar si existe un entorno virtual en el directorio actual
      local cwd_venv = vim.fn.getcwd() .. "/venv/bin/python"
      if vim.fn.executable(cwd_venv) == 1 then
        -- Usar el entorno virtual del proyecto actual
        require("dap-python").setup(cwd_venv)
      elseif vim.fn.executable(vim.fn.expand("~/.virtualenvs/debugpy/bin/python")) == 1 then
        -- Usar el entorno virtual específico para debugpy
        require("dap-python").setup(vim.fn.expand("~/.virtualenvs/debugpy/bin/python"))
      elseif vim.fn.has("win32") == 1 then
        -- Fallback para Windows
        require("dap-python").setup(require("lazyvim.util").get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
      else
        -- Fallback para otros sistemas
        require("dap-python").setup(require("lazyvim.util").get_pkg_path("debugpy", "/venv/bin/python"))
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ruff", "pyright", "debugpy" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end, -- Dejamos que nvim-dap-python maneje esto
      },
    },
  },
}
