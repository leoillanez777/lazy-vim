-- Archivo: lua/config/frameworks.lua
local M = {}

function M.setup()
  -- Cargar el detector de frameworks
  local detector = require("config.framework_detector")

  local detected = detector.setup()

  -- Crear una variable global con el tipo de proyecto
  if detected.vue then
    vim.g.project_type = "vue"
  elseif detected.angular then
    vim.g.project_type = "angular"
  elseif detected.react then
    vim.g.project_type = "react"
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
          elseif vim.g.project_type == "react" then
            return "⚛ React"
          else
            return ""
          end
        end,
        cond = function()
          return vim.g.project_type ~= "generic"
        end,
        color = function()
          if vim.g.project_type == "vue" then
            return { fg = "#41b883", gui = "bold" } -- Color de Vue
          elseif vim.g.project_type == "react" then
            return { fg = "#61dafb", gui = "bold" } -- Color de React
          else
            return { fg = "#DD0031", gui = "bold" } -- Color de Angular
          end
        end,
      }

      -- Añadir a la sección apropiada
      table.insert(config.sections.lualine_x, 1, project_type)
      lualine.setup(config)
    end, 100) -- Pequeño retraso para asegurar que lualine esté cargado
  end

  return detected
end

return M
