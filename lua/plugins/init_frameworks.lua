-- init_frameworks.lua
-- Este archivo debe ir en la carpeta lua/plugins/

return {
  "LazyVim/LazyVim",
  priority = 10000, -- Asegura que se cargue primero
  lazy = false,
  config = function()
    -- Cargar el detector de frameworks
    local detector = require("framework_detector")
    local detected = detector.setup()
    -- Crear una variable global con el tipo de proyecto
    if detected.vue then
      vim.g.project_type = "vue"
    elseif detected.angular then
      vim.g.project_type = "angular"
    else
      vim.g.project_type = "generic"
    end
    -- Añadir información al statusline si usas lualine
    if LazyVim.has("lualine.nvim") then
      vim.defer_fn(function()
        local lualine = require("lualine")
        local config = lualine.get_config()
        -- Agregar componente para mostrar el tipo de proyecto
        local project_type = {
          function()
            if vim.g.project_type == "vue" then
              return " Vue"
            elseif vim.g.project_type == "angular" then
              return " Angular"
            else
              return ""
            end
          end,
          cond = function()
            return vim.g.project_type ~= "generic"
          end,
          color = { fg = "#41b883", gui = "bold" }, -- Color de Vue por defecto
        }

        -- Añadir a la sección apropiada
        table.insert(config.sections.lualine_x, 1, project_type)
        lualine.setup(config)
      end, 100) -- Pequeño retraso para asegurar que lualine esté cargado
    end
  end,
}
