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
  end,
}
