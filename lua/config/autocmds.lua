-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function notify_debug(msg, level)
  -- Niveles disponibles: "error", "warn", "info", "debug", "trace"
  level = level or "info"
  vim.notify(msg, vim.log.levels[string.upper(level)], {
    title = "Project Detection",
    timeout = 5000, -- 5 segundos
    render = "default",
  })
end

-- Global Functions.
_G.is_angular_project = function(bufnr)
  local angular_files = vim.fs.find({ "angular.json", "project.json", ".angular-cli.json" }, {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]

  if angular_files then
    return true
  end
  -- Verificar package.json para Angular
  local package_json = vim.fs.find("package.json", {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]

  if package_json then
    local content = vim.fn.json_decode(vim.fn.readfile(package_json))
    return (content.dependencies and content.dependencies["@angular/core"])
      or (content.devDependencies and content.devDependencies["@angular/core"])
  end
  return false
end

_G.is_vue_project = function(bufnr)
  local vue_files = vim.fs.find({
    "vue.config.js",
    "nuxt.config.js",
    "vite.config.js",
  }, {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]

  if vue_files then
    return true
  end

  -- Verificar package.json para Vue
  local package_json = vim.fs.find("package.json", {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]

  if package_json then
    local content = vim.fn.json_decode(vim.fn.readfile(package_json))
    return content.dependencies
      and (content.dependencies.vue or content.devDependencies and content.devDependencies.vue)
  end
  return false
end

-- Función para manejar los clientes LSP
local function handle_lsp_clients(bufnr, is_angular)
  -- Esperamos un poco para asegurarnos de que los clientes LSP estén adjuntos
  vim.defer_fn(function()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if is_angular and client.name == "volar" then
        notify_debug("Detaching Volar from Angular project", "warn")
        vim.lsp.buf_detach_client(bufnr, client.id)
        vim.notify("Detached Volar from Angular file", vim.log.levels.INFO)
      elseif not is_angular and client.name == "angularls" then
        notify_debug("Detaching Angular LS from Vue project", "warn")
        vim.lsp.buf_detach_client(bufnr, client.id)
        vim.notify("Detached Angular LS from Vue file", vim.log.levels.INFO)
      end
    end
  end, 3000) -- Espera 3 segundo
end

-- Configuración de autocomandos
local group = vim.api.nvim_create_augroup("ProjectTypeDetection", { clear = true })

-- Autocomando para la detección de tipo de proyecto
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*.ts", "*.js", "*.html", "*.vue", "*.css", "*.scss" },
  callback = function(ev)
    local bufnr = ev.buf
    local filetype = vim.fn.expand("%:e")

    if _G.is_angular_project(bufnr) then
      notify_debug("Angular project detected", "info")
      if filetype == "html" then
        vim.bo.filetype = "htmlangular"
      elseif filetype == "ts" then
        vim.bo.filetype = "typescript"
      elseif filetype == "css" or filetype == "scss" then
        vim.bo[bufnr].filetype = filetype
      end
      handle_lsp_clients(bufnr, true)
      vim.schedule(function()
        vim.cmd("LspStart angularls")
      end)
    elseif _G.is_vue_project(bufnr) then
      notify_debug("Vue project detected", "info")
      if filetype == "vue" then
        vim.bo[bufnr].filetype = "vue"
      elseif filetype == "ts" then
        vim.bo[bufnr].filetype = "typescript"
      elseif filetype == "js" then
        vim.bo[bufnr].filetype = "javascript"
      elseif filetype == "css" or filetype == "scss" then
        vim.bo[bufnr].filetype = filetype
      end
      handle_lsp_clients(bufnr, false)
      vim.schedule(function()
        vim.cmd("LspStart volar")
      end)
    elseif filetype == "html" then
      vim.bo[bufnr].filetype = "html"
    end
  end,
})

-- Autocomando adicional para manejar la adjunción de clientes LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
      return
    end
    local bufnr = ev.buf
    print("LSP attached:", client.name, "to buffer:", bufnr)

    if is_angular_project(bufnr) and client.name == "volar" then
      print("Preventing Volar attachment to Angular file")
      vim.lsp.buf_detach_client(bufnr, client.id)
    elseif is_vue_project(bufnr) and client.name == "angularls" then
      print("Preventing Angular LS attachment to Vue file")
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end,
})
