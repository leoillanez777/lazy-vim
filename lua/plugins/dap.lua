return {
  "mfussenegger/nvim-dap",
  lazy = true,
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({ ensure_installed = { "firefox", "node2" } })
    end,
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "anuvyklack/hydra.nvim",
    "nvim-telescope/telescope-dap.nvim",
    "rcarriga/cmp-dap",
    "leoluz/nvim-dap-go",
    "nvim-neotest/nvim-nio",
  },
  keys = {
    { "<leader>d", desc = "Debug menu" },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = " Breakpoint Condition",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = " Toggle Breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = " Continue",
    },
    {
      "<leader>da",
      function()
        require("dap").continue({ before = get_args })
      end,
      desc = " Run with Args",
    },
    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = " Run to Cursor",
    },
    {
      "<leader>dg",
      function()
        require("dap").goto_()
      end,
      desc = "Go to Line (No Execute)",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = " Step Into",
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = "Down",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = "Up",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run Last",
    },
    {
      "<leader>do",
      function()
        require("dap").step_out()
      end,
      desc = " Step Out",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_over()
      end,
      desc = " Step Over",
    },
    {
      "<leader>dp",
      function()
        require("dap").pause()
      end,
      desc = " Pause",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle REPL",
    },
    {
      "<leader>ds",
      function()
        require("dap").session()
      end,
      desc = "Session",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = " Terminate",
    },
    {
      "<leader>dw",
      function()
        require("dap.ui.widgets").hover()
      end,
      desc = " Widgets",
    },
    {
      "<leader>dx",
      function()
        vim.ui.input({ prompt = "Ingrese el nombre del proyecto: " }, function(input)
          if input then
            local csproj_file = input .. ".csproj"
            local cmd = string.format(
              "dotnet build %s /property:GenerateFullPaths=true /consoleloggerparameters:NoSummary",
              csproj_file
            )
            -- Ejecutar el comando y capturar la salida
            local output = vim.fn.system(cmd)
            -- Verificar si hubo algún error
            if vim.v.shell_error ~= 0 then
              -- Mostrar el error en una ventana flotante
              vim.api.nvim_err_writeln("Error al compilar " .. csproj_file .. ":")
              vim.api.nvim_echo({ { output, "ErrorMsg" } }, true, {})
            else
              print("Compilación exitosa: " .. csproj_file)
            end
          else
            print("No se especificó un nombre de proyecto.")
          end
        end)
      end,
      desc = " Build .NET Project", -- Ícono de herramientas
    },
  },
  cmd = {
    "DapContinue",
    "DapLoadLaunchJSON",
    "DapRestartFrame",
    "DapSetLogLevel",
    "DapShowLog",
    "DapStepInto",
    "DapStepOut",
    "DapStepOver",
    "DapTerminate",
    "DapToggleBreakpoint",
    "DapToggleRepl",
  },
  config = function()
    local ok_telescope, telescope = pcall(require, "telescope")
    if ok_telescope then
      telescope.load_extension("dap")
    end

    local ok_cmp, cmp = pcall(require, "cmp")
    if ok_cmp then
      cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
        sources = cmp.config.sources({
          { name = "dap" },
        }, {
          { name = "buffer" },
        }),
      })
    end

    -- load mason-nvim-dap here, after all adapters have been setup
    if LazyVim.has("mason-nvim-dap.nvim") then
      require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
    end

    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    for name, sign in pairs(LazyVim.config.icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end

    -- setup dap config by VsCode launch.json file
    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

    -- Extends dap.configurations with entries read from .vscode/launch.json
    if vim.fn.filereadable(".vscode/launch.json") then
      vscode.load_launchjs()
    end

    local function load_env_variables()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        variables[k] = v
      end
      -- Cargar variables desde el archivo .env manualmente
      local env_file_path = vim.fn.getcwd() .. "/.env"
      local env_file = io.open(env_file_path, "r")
      if env_file then
        for line in env_file:lines() do
          for key, value in string.gmatch(line, "([%w_]+)=([%w_]+)") do
            variables[key] = value
          end
        end
        env_file:close()
      else
        print("Error: .env file not found in " .. env_file_path)
      end
      return variables
    end

    local dap = require("dap")

    -- Añade la propiedad env a cada configuración de Go existente
    for _, config in pairs(dap.configurations.go or {}) do
      config.env = load_env_variables
    end
  end,
}
