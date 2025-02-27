-- init_frameworks.lua

return {
  "LazyVim/LazyVim",
  lazy = false,
  priority = 10000,
  init = function()
    -- Registramos un callback para VimEnter que se ejecutará después de que todo se haya inicializado
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.defer_fn(function()
          local ok, framework = pcall(require, "config.framework")
          if ok then
            framework.setup()
          else
            vim.notify("Error al cargar el detector de frameworks: " .. tostring(framework), vim.log.levels.ERROR)
          end
        end, 100) -- Pequeño retraso para asegurar que todo esté listo
      end,
      once = true,
    })
  end,
}
