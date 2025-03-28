return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "csharpier", "netcoredbg" } },
  },
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      { "rcarriga/nvim-dap-ui", lazy = true, event = "VeryLazy" },
      { "theHamsta/nvim-dap-virtual-text", lazy = true, event = "VeryLazy" },
      { "ibhagwan/fzf-lua", lazy = true },
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
    end,
  },
  {
    "Cliffback/netcoredbg-macOS-arm64.nvim",
    lazy = true,
    event = "VeryLazy",
    cond = function()
      return vim.fn.executable("/usr/local/netcoredbg") == 1
    end,
    config = function()
      local dap = require("dap")
      require("netcoredbg-macOS-arm64").setup(require("dap"))
      dap.adapters.coreclr = {
        type = "executable",
        command = "/usr/local/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- Función para encontrar todos los archivos .csproj en el directorio actual y sus subdirectorios
      local function find_csproj_files()
        local handle = io.popen("find . -name '*.csproj'")
        if not handle then
          vim.notify("Error al ejecutar find", vim.log.levels.ERROR)
          return {}
        end
        local result = handle:read("*a")
        handle:close()
        local files = {}
        for file in result:gmatch("[^\r\n]+") do
          table.insert(files, file:sub(3)) -- Elimina "./" del inicio
        end
        return files
      end

      -- Función para compilar todos los proyectos
      local function build_all_projects()
        local csproj_files = find_csproj_files()
        for _, file in ipairs(csproj_files) do
          local cmd =
            string.format("dotnet build %s /property:GenerateFullPaths=true /consoleloggerparameters:NoSummary", file)
          local output = vim.fn.system(cmd)
          if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln("Error al compilar " .. file .. ":")
            vim.api.nvim_echo({ { output, "ErrorMsg" } }, true, {})
          else
            print("Compilación exitosa: " .. file)
          end
        end
      end

      -- Función para encontrar el archivo DLL más probable para depurar
      local function find_debug_dll()
        local csproj_files = find_csproj_files()
        local possible_dlls = {}

        for _, csproj in ipairs(csproj_files) do
          local project_dir = vim.fn.fnamemodify(csproj, ":h")
          local project_name = vim.fn.fnamemodify(csproj, ":t:r")
          local possible_dll = string.format("%s/bin/Debug/net8.0/%s.dll", project_dir, project_name)

          if vim.fn.filereadable(possible_dll) == 1 then
            table.insert(possible_dlls, possible_dll)
          end
        end

        if #possible_dlls == 0 then
          return vim.fn.input(
            "No se encontraron DLLs. Ingrese la ruta al DLL: ",
            vim.fn.getcwd() .. "/bin/Debug/net8.0/",
            "file"
          )
        elseif #possible_dlls == 1 then
          return possible_dlls[1]
        else
          return vim.fn.input("Seleccione el DLL para depurar: ", possible_dlls[1], "file")
        end
      end

      -- Función para seleccionar proyectos
      local function select_projects(_)
        -- Proyecto principal por defecto
        local startup_project = vim.fn.input("Proyecto de inicio (--startup-project): ", "", "file")
        if startup_project == "" then
          print("No se especificó el proyecto de inicio")
          return nil, nil
        end

        -- Proyecto de datos por defecto
        local data_project = vim.fn.input("Proyecto de datos (--project): ", "", "file")
        if data_project == "" then
          print("No se especificó el proyecto de datos")
          return nil, nil
        end

        return startup_project, data_project
      end

      -- función para ejecutar dotnet ef migrations
      local function run_ef_migrations()
        local csproj_files = find_csproj_files()
        if #csproj_files == 0 then
          print("No se encontraron archivos .csproj")
          return
        end

        -- Seleccionar proyectos
        local startup_project, data_project = select_projects(csproj_files)
        if not startup_project or not data_project then
          return
        end

        -- Obtener nombre de la migración
        local migration_name = vim.fn.input("Nombre de la migración: ")
        if migration_name == "" then
          print("Nombre de migración inválido")
          return
        end

        -- Comando para agregar la migración
        local add_cmd = string.format(
          "dotnet ef migrations add %s --project %s --startup-project %s",
          migration_name,
          data_project,
          startup_project
        )
        -- Ejecutar el comando de migración
        local output = vim.fn.system(add_cmd)
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_err_writeln("Error al crear la migración:")
          vim.api.nvim_echo({ { output, "ErrorMsg" } }, true, {})
          return
        end
        print("Migración creada exitosamente: " .. migration_name)

        -- Preguntar si desea actualizar la base de datos
        local update_db = vim.fn.input("¿Desea actualizar la base de datos? (y/N): ")
        if update_db:lower() == "y" then
          local update_cmd =
            string.format("dotnet ef database update --project %s --startup-project %s", data_project, startup_project)
          local update_output = vim.fn.system(update_cmd)
          if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln("Error al actualizar la base de datos:")
            vim.api.nvim_echo({ { update_output, "ErrorMsg" } }, true, {})
          else
            print("Base de datos actualizada exitosamente")
          end
        end
      end

      -- Función para ejecutar dotnet ef database update
      local function run_ef_database_update()
        local csproj_files = find_csproj_files()
        local csproj_file
        if #csproj_files == 0 then
          print("No se encontraron archivos .csproj")
          return
        elseif #csproj_files == 1 then
          csproj_file = csproj_files[1]
        else
          csproj_file = vim.fn.input("Seleccione el archivo .csproj: ", csproj_files[1], "file")
        end

        local project_dir = vim.fn.fnamemodify(csproj_file, ":h")

        local cmd = string.format("cd %s && dotnet ef database update", project_dir)
        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_err_writeln("Error al actualizar la base de datos:")
          vim.api.nvim_echo({ { output, "ErrorMsg" } }, true, {})
        else
          print("Base de datos actualizada exitosamente")
        end
      end

      ---@class DapConfiguration
      ---@field programPath string|nil
      ---@field type string
      ---@type DapConfiguration[]
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg - neovim",
          request = "launch",
          programPath = "",
          program = function()
            if not dap.configurations.cs[1].programPath then
              dap.configurations.cs[1].programPath = find_debug_dll()
            end
            return dap.configurations.cs[1].programPath
          end,
          cwd = "${workspaceFolder}",
        },
      }

      -- Agregor un atajo para compilar todos los proyectos
      vim.keymap.set("n", "<leader>dX", function()
        build_all_projects()
      end, { desc = " Build All .NET Projects" })

      -- keymap para ejecutar dotnet ef migrations
      vim.keymap.set("n", "<leader>dm", function()
        run_ef_migrations()
      end, { desc = "󱘭 Run dotnet ef migrations" })

      -- keymap para ejecutar dotnet ef database update
      vim.keymap.set("n", "<leader>du", function()
        run_ef_database_update()
      end, { desc = "󰳿 Run dotnet ef database update" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          keys = {
            {
              "gd",
              LazyVim.has("telescope.nvim") and function()
                require("omnisharp_extended").telescope_lsp_definitions()
              end or function()
                require("omnisharp_extended").lsp_definitions()
              end,
              desc = "Goto Definition",
            },
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "dotnet-csharpier",
          args = { "--write-stdout" },
        },
      },
    },
  },
}
