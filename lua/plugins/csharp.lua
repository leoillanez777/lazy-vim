return {
  "Cliffback/netcoredbg-macOS-arm64.nvim",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    local dap = require("dap")
    require("netcoredbg-macOS-arm64").setup(require("dap"))

    dap.adapters.coreclr = {
      type = "executable",
      command = "/usr/local/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
        end,
      },
    }
  end,
}
