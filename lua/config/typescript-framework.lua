local M = {}

-- Detect TypeScript version from project
function M.get_typescript_version()
  local cwd = vim.fn.getcwd()
  local package_json = vim.fn.findfile("package.json", cwd .. ";")

  if package_json ~= "" then
    local content = table.concat(vim.fn.readfile(package_json), "\n")
    local json = vim.fn.json_decode(content)

    local ts_version = nil

    -- Check dependencies and devDependencies for typescript
    if json.dependencies and json.dependencies.typescript then
      ts_version = json.dependencies.typescript
    elseif json.devDependencies and json.devDependencies.typescript then
      ts_version = json.devDependencies.typescript
    end

    if ts_version then
      -- Extract version number (remove ^ or ~ if present)
      ts_version = ts_version:gsub("^[%^~]", "")
      vim.notify("TypeScript version detected: " .. ts_version, vim.log.levels.INFO)
      return ts_version
    end
  end

  return nil
end

-- Check if this is a legacy TypeScript project (pre 4.0)
function M.is_legacy_typescript()
  local version = M.get_typescript_version()
  if not version then
    return false
  end

  -- Extract major version number
  local major = tonumber(version:match("^(%d+)"))
  if major and major < 4 then
    vim.notify("Legacy TypeScript detected (< 4.0). Using vtsls for better compatibility.", vim.log.levels.INFO)
    return true
  end

  return false
end

-- Check if this is an Angular project and determine which version
function M.get_angular_version()
  local cwd = vim.fn.getcwd()
  local package_json = vim.fn.findfile("package.json", cwd .. ";")

  if package_json ~= "" then
    local content = table.concat(vim.fn.readfile(package_json), "\n")
    local json = vim.fn.json_decode(content)

    local angular_version = nil

    -- Check for @angular/core in dependencies
    if json.dependencies and json.dependencies["@angular/core"] then
      angular_version = json.dependencies["@angular/core"]
    elseif json.devDependencies and json.devDependencies["@angular/core"] then
      angular_version = json.devDependencies["@angular/core"]
    end

    if angular_version then
      -- Extract major version number
      angular_version = angular_version:gsub("^[%^~]", "")
      local major = tonumber(angular_version:match("^(%d+)"))

      vim.notify("Angular version detected: " .. angular_version, vim.log.levels.INFO)
      return angular_version, major
    end
  end

  return nil, nil
end

-- Determine if we should use Angular LSP based on version
function M.should_use_angular_lsp()
  local _, major_version = M.get_angular_version()

  -- For Angular 12+ we recommend using angularls
  if major_version and major_version >= 12 then
    vim.notify("Modern Angular detected (v" .. major_version .. "). Using angularls.", vim.log.levels.INFO)
    return true
  elseif major_version then
    vim.notify(
      "Legacy Angular detected (v" .. major_version .. "). Using vtsls for better compatibility.",
      vim.log.levels.INFO
    )
    return false
  end

  return false
end

return M
