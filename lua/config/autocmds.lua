-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "vue",
  callback = function(args)
    vim.schedule(function()
      local clients = vim.lsp.get_clients({ bufnr = args.buf })
      print("LSP clients for Vue file:")
      for _, client in pairs(clients) do
        print(string.format("- %s (id: %d)", client.name, client.id))
      end
    end)
  end,
})
