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
  "mfussenegger/nvim-dap",
  lazy = true,
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "firefox", "node2" },
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })
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
      "<F3>",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = " Breakpoint Condition",
    },
    {
      "<F4>",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = " Toggle Breakpoint",
    },
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = " Continue",
    },
    {
      "<F6>",
      function()
        require("dap").continue({ before = get_args })
      end,
      desc = " Run with Args",
    },
    {
      "<F7>",
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
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "󰆹 Step Into",
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = " Down",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = " Up",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "󰘁 Run Last",
    },
    {
      "<F9>",
      function()
        require("dap").step_out()
      end,
      desc = "󰆸 Step Out",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = " Step Over",
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
      desc = " Toggle REPL",
    },
    {
      "<leader>ds",
      function()
        require("dap").session()
      end,
      desc = "Session",
    },
    {
      "<F8>",
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

    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    for name, sign in pairs(LazyVim.config.icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end

    -- setup dap config by VsCode launch.json file
    local dap = require("dap")
    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")

    ---@diagnostic disable-next-line: duplicate-set-field
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

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
      config.env = load_env_variables
    end
  end,
}
