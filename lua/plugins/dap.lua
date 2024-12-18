---@return table
local function get_args()
  local args = {}
  local input = vim.fn.input("Arguments: ")
  if input ~= "" then
    for arg in input:gmatch("%S+") do
      table.insert(args, arg)
    end
  end
  return args
end

return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,

      handlers = {},
      ensure_installed = { "csharpier", "netcoredbg" },
    },
    config = function() end,
  },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    recommended = true,
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    dependencies = {
      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        event = "VeryLazy",
        opts = {},
      },
    },

    -- stylua: ignore
    keys = {
      { "<F3>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<F4>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<F5>", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>d<F5>", function() require("dap").continue() end, desc = " Run/Continue" },
      { "<F6>", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<F7>", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<F9>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<F8>", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
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
      -- load mason-nvim-dap here, after all adapters have been setup
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          ---@diagnostic disable-next-line: assign-type-mismatch
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      ---@diagnostic disable-next-line: duplicate-set-field
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      -- setup dap config by VsCode launch.json file
      local dap = require("dap")

      -- Función para buscar launch.json en la carpeta actual y la superior
      local function find_launch_json()
        local root_patterns = { ".git", ".vscode", "*.sln", "*.csproj" }
        local root_dir

        -- Buscar el directorio raíz del proyecto
        for _, pattern in ipairs(root_patterns) do
          root_dir = vim.fs.find(pattern, {
            upward = true,
            type = "file",
            path = vim.fn.getcwd(),
          })[1]
          if root_dir then
            root_dir = vim.fn.fnamemodify(root_dir, ":h")
            break
          end
        end

        if not root_dir then
          return nil
        end

        local launch_json = root_dir .. "/.vscode/launch.json"
        if vim.fn.filereadable(launch_json) == 1 then
          return launch_json
        end

        return nil
      end

      -- Función para cargar launch.json
      local function load_launch_json()
        local launch_json_path = find_launch_json()
        if launch_json_path then
          vscode.load_launchjs(launch_json_path, {
            cppdbg = { "c", "cpp" },
            coreclr = { "cs" },
            ["pwa-node"] = { "typescript", "javascript" },
          })
          vim.notify("Launch.json cargado: " .. launch_json_path, vim.log.levels.INFO)
        end
      end

      -- Cargar launch.json al iniciar DAP
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cs", "typescript", "javascript" },
        callback = function()
          load_launch_json()
        end,
      })

      -- Función para elegir configuración
      local function choose_configuration()
        local launch_json_path = find_launch_json()
        if launch_json_path then
          local configs = dap.configurations[vim.bo.filetype] or {}
          if #configs > 0 then
            vim.ui.select(configs, {
              prompt = "Elige una configuración de depuración:",
              format_item = function(config)
                return config.name
              end,
            }, function(config)
              if config then
                dap.run(config)
              end
            end)
          else
            print("No hay configuraciones disponibles para este tipo de archivo.")
          end
        else
          print("No se encontró el archivo launch.json. Ejecutando la configuración por defecto.")
          dap.continue()
        end
      end

      -- Configuración por defecto si no hay launch.json
      dap.configurations.cs = dap.configurations.cs
        or {
          {
            type = "coreclr",
            name = "Launch - NetCoreDbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
          },
        }

      -- Reemplaza la tecla existente para iniciar la depuración
      vim.keymap.set("n", "<leader>dc", choose_configuration, { desc = " Choose Debug Configuration" })

      -- Agrega una tecla para recargar launch.json
      vim.keymap.set("n", "<leader>dR", load_launch_json, { desc = "󰑓 Reload launch.json" })

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

      -- Añade la propiedad env a cada configuración de Go existente
      for _, config in pairs(dap.configurations.go or {}) do
        ---@diagnostic disable-next-line: inject-field
        config.env = load_env_variables
      end
    end,
  },
}
