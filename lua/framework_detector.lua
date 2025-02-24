-- Este archivo detecta automáticamente el tipo de proyecto (Vue o Angular)

local M = {}

-- Función para detectar el tipo de framework en el proyecto actual
function M.detect_framework()
  local frameworks = {
    vue = {
      files = { "vue.config.js", "vite.config.ts", "nuxt.config.js", "nuxt.config.ts" },
      dirs = { "components" },
      package_deps = { "vue", "nuxt" },
    },
    angular = {
      files = { "angular.json", "project.json", ".angular-cli.json" },
      dirs = {},
      package_deps = { "@angular/core" },
    },
  }

  local result = { vue = false, angular = false }

  -- Buscar archivos de configuración característicos de cada framework
  for framework, config in pairs(frameworks) do
    -- Buscar archivos de configuración
    for _, file in ipairs(config.files) do
      if vim.fn.findfile(file, ".;") ~= "" then
        result[framework] = true
        break
      end
    end

    -- Buscar directorios característicos
    for _, dir in ipairs(config.dirs) do
      if vim.fn.isdirectory(vim.fn.finddir(dir, ".;")) == 1 then
        result[framework] = true
        break
      end
    end

    -- Verificar en package.json si no se ha detectado aún
    if not result[framework] and vim.fn.filereadable("package.json") == 1 then
      local package_json = vim.fn.readfile("package.json")
      local package_content = table.concat(package_json, "\n")

      for _, dep in ipairs(config.package_deps) do
        if string.find(package_content, dep) then
          result[framework] = true
          break
        end
      end
    end
  end

  return result
end

-- Función para configurar LSPs y herramientas según el framework detectado
function M.setup()
  local detected = M.detect_framework()

  -- Guardar la información detectada como variables globales para usar en otros archivos
  vim.g.is_vue_project = detected.vue
  vim.g.is_angular_project = detected.angular

  -- Salida de log para debug
  if detected.vue then
    vim.notify("Vue project detected", vim.log.levels.INFO)
  end

  if detected.angular then
    vim.notify("Angular project detected", vim.log.levels.INFO)
  end

  return detected
end

return M
