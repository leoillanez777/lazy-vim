return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap_local = require("dap")
      local dapui_local = require("dapui")
      dapui_local.setup()
      dap_local.listeners.after.event_initialized["dapui_config"] = function()
        dapui_local.open()
      end
      dap_local.listeners.before.event_terminated["dapui_config"] = function()
        dapui_local.close()
      end
      dap_local.listeners.before.event_exited["dapui_config"] = function()
        dapui_local.open()
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "pyright", "debugpy", "ruff", "black", "mypy" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          analysis = {
            reportLineTooLong = "none",
          },
        },
        ruff_lsp = {
          init_options = {
            settings = {
              args = {
                "--ignore=E501",
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    recommended = true,
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    dependencies = {
      "rcarriga/nvim-dap-ui",
      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local path = "~/.virtualenvs/debugpy/bin/python3.12"
      require("dap-python").setup(path)
      local dap = require("dap")
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "My custom launch configuration",
        program = "${file}",
        -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
      })
    end,
  },
}
