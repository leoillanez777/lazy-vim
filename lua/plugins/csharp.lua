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

    -- Función para encontrar todos los archivos .csproj en el directorio actual y sus subdirectorios
    local function find_csproj_files()
      local handle = io.popen("find . -name '*.csproj'")
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

    -- función para ejecutar dotnet ef migrations
    local function run_ef_migrations()
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
      local migration_name = vim.fn.input("Nombre de la migración: ")
      if migration_name == "" then
        print("Nombre de migración inválido")
        return
      end

      local cmd = string.format("cd %s && dotnet ef migrations add %s", project_dir, migration_name)
      local output = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("Error al crear la migración:")
        vim.api.nvim_echo({ { output, "ErrorMsg" } }, true, {})
      else
        print("Migración creada exitosamente: " .. migration_name)
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

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg - neovim",
        request = "launch",
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
}
