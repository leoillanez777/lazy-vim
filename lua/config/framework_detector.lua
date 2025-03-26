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
  local cwd = vim.fn.getcwd()

  -- Utilidad para buscar archivos recursivamente desde el directorio actual
  local function find_file(file)
    local found = vim.fn.findfile(file, cwd .. ";")
    return found
  end

  -- Utilidad para buscar directorios
  local function find_dir(dir)
    local found = vim.fn.finddir(dir, cwd .. ";")
    return found
  end

  -- Buscar archivos de configuración característicos de cada framework
  for framework, config in pairs(frameworks) do
    -- Buscar archivos de configuración
    for _, file in ipairs(config.files) do
      local found_file = find_file(file)
      if found_file ~= "" then
        vim.notify(
          "Framework detectado (" .. framework .. "): archivo " .. file .. " encontrado en " .. found_file,
          vim.log.levels.DEBUG
        )
        result[framework] = true
        break
      end
    end

    if result[framework] then
      goto continue
    end

    -- Buscar directorios característicos
    for _, dir in ipairs(config.dirs) do
      local found_dir = find_dir(dir)
      if found_dir ~= "" then
        vim.notify(
          "Framework detectado (" .. framework .. "): directorio " .. dir .. " encontrado",
          vim.log.levels.DEBUG
        )
        result[framework] = true
        break
      end
    end

    if result[framework] then
      goto continue
    end

    -- Verificar en package.json si no se ha detectado aún
    local package_json = find_file("package.json")
    if package_json ~= "" then
      local content = table.concat(vim.fn.readfile(package_json), "\n")
      for _, dep in ipairs(config.package_deps) do
        if string.find(content, '"' .. dep .. '"') then
          vim.notify(
            "Framework detectado (" .. framework .. "): dependencia " .. dep .. " encontrada en package.json",
            vim.log.levels.DEBUG
          )
          result[framework] = true
          break
        end
      end
    end

    ::continue::
  end

  return result
end

-- Función para configurar LSPs y herramientas según el framework detectado
function M.setup()
  local detected = M.detect_framework()

  -- Guardar la información detectada como variables globales para usar en otros archivos
  vim.g.is_vue_project = detected.vue
  vim.g.is_angular_project = detected.angular

  -- Notificar el tipo de proyecto detectado con un nivel más alto para asegurar visibilidad
  if detected.vue then
    vim.notify("Vue project detected", vim.log.levels.INFO)
  elseif detected.angular then
    vim.notify("Angular project detected", vim.log.levels.INFO)
    -- Para proyectos Angular, verificamos la versión para decidir qué LSP usar
    local ts_framework = require("config.typescript-framework")
    local version, major = ts_framework.get_angular_version()

    if version then
      if major and major >= 12 then
        vim.notify("Modern Angular detected (v" .. major .. "). Using angularls is recommended.", vim.log.levels.INFO)
      else
        vim.notify(
          "Legacy Angular detected (v" .. major .. "). Using vtsls for better compatibility.",
          vim.log.levels.INFO
        )
      end
    end
  else
    -- Para proyectos no-Angular, verificar la versión de TypeScript
    if detected.vue == false and detected.angular == false then
      local ts_framework = require("config.typescript-framework")
      local version = ts_framework.get_typescript_version()

      if version then
        local major = tonumber(version:match("^(%d+)"))
        if major and major < 4 then
          vim.notify(
            "Legacy TypeScript detected (v" .. version .. "). Using vtsls for better compatibility.",
            vim.log.levels.INFO
          )
        else
          vim.notify("Modern TypeScript detected (v" .. version .. "). Using tsserver.", vim.log.levels.INFO)
        end
      end
    end
  end

  return detected
end

return M
