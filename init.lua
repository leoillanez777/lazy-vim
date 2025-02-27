-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Detectar el framework después de que se haya cargado todo
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    -- Usamos defer_fn para asegurar que se ejecute después de todo lo demás
    vim.defer_fn(function()
      local ok, framework = pcall(require, "config.framework")
      if ok then
        vim.notify("Iniciando detección de frameworks desde init.lua", vim.log.levels.INFO)
        framework.setup()
      else
        vim.notify("Error al cargar el detector de frameworks desde init.lua", vim.log.levels.ERROR)
      end
    end, 200)
  end,
})
