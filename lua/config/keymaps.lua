-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Definir una funcion para insertar acentos.
local function insert_accent(char)
  return function()
    -- vim.api.nvim_put({ char }, "c", true, true)
    -- vim.api.nvim_input("<BS>" .. char)
    vim.api.nvim_input(char)
  end
end

vim.keymap.set("i", "]a", insert_accent("á"), { desc = "Insertar á" })
vim.keymap.set("i", "]e", insert_accent("é"), { desc = "Insertar é" })
vim.keymap.set("i", "]i", insert_accent("í"), { desc = "Insertar í" })
vim.keymap.set("i", "]o", insert_accent("ó"), { desc = "Insertar ó" })
vim.keymap.set("i", "]u", insert_accent("ú"), { desc = "Insertar ú" })
vim.keymap.set("i", "]n", insert_accent("ñ"), { desc = "Insertar ñ" })
vim.keymap.set("i", "]A", insert_accent("Á"), { desc = "Insertar Á" })
vim.keymap.set("i", "]E", insert_accent("É"), { desc = "Insertar É" })
vim.keymap.set("i", "]I", insert_accent("Í"), { desc = "Insertar Í" })
vim.keymap.set("i", "]O", insert_accent("Ó"), { desc = "Insertar Ó" })
vim.keymap.set("i", "]U", insert_accent("Ú"), { desc = "Insertar Ú" })
vim.keymap.set("i", "]N", insert_accent("Ñ"), { desc = "Insertar Ñ" })

-- Select text in insert mode
vim.keymap.set("i", "<C-h>", "<Esc>vb", { desc = "Seleccionar palabra anterior" })
vim.keymap.set("i", "<C-l>", "<Esc>ve", { desc = "Seleccionar siguiente palabra" })
vim.keymap.set("i", "<S-Tab>", "<Esc>vec", { desc = "Seleccionar y editar siguiente palabra" })
-- Go to end the line in insert mode
vim.keymap.set("i", "<C-e>", "<Esc>l$a", { desc = "Mover cursor al final de la línea" })
-- Go to beginning of line in insert mode
vim.keymap.set("i", "<C-w>", "<Esc>I", { desc = "Mover cursor al principio de la línea" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "vue" },
  callback = function()
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = true })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = true })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = true })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = true })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = true })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = true })
  end,
})

-- Agregar comando GitConflictListQF al menú de Git bajo <leader>g
local wk = require("which-key")
wk.add({
  { "<leader>F", group = "Fugit 2", icon = { icon = "", color = "orange" } },
  { "<leader>g", group = "git" },
  { "<leader>gC", group = " Conflictos" },
  { "<leader>d", group = "Debbuger", icon = "" },
  { "<leader>C", group = "Codeium", icon = {
    icon = "",
    color = "azure",
  } },
  { "<leader>cf", group = "Format", icon = "" },
  { "<leader>a", group = "Avante", icon = "󰧑" },
})

-- Codeium
vim.keymap.set("n", "<leader>Cc", "<cmd>Codeium Chat<cr>", { desc = "󰈌 Codeium Chat" })

-- Git Conflict
vim.keymap.set("n", "<leader>gCo", "<cmd>GitConflictChooseOurs<cr>", { desc = " Escoger los cambios actuales" })
vim.keymap.set("n", "<leader>gCt", "<cmd>GitConflictChooseTheirs<cr>", { desc = " Escoger los cambios entrantes" })
vim.keymap.set("n", "<leader>gCb", "<cmd>GitConflictChooseBoth<cr>", { desc = " Escoger ambos cambios" })
vim.keymap.set("n", "<leader>gCe", "<cmd>GitConflictChooseNone<cr>", { desc = "󰝾 Escoger ninguno de los cambios" })
vim.keymap.set("n", "<leader>gCn", "<cmd>GitConflictNextConflict<cr>", { desc = " Siguiente conflicto" })
vim.keymap.set("n", "<leader>gCN", "<cmd>GitConflictPrevConflict<cr>", { desc = " Conflicto anterior" })
vim.keymap.set("n", "<leader>gCl", "<cmd>GitConflictListQf<cr>", { desc = " Lista de conflictos" })
vim.keymap.set("n", "<leader>gCa", "<cmd>Gwrite<cr>", { desc = " Grabar Cambios" })

-- Agregar una opción para ejecutar :LspRestart con <leader>x -> r, con icono de reinicio 
vim.keymap.set("n", "<leader>xr", "<cmd>LspRestart<cr>", { desc = " Reiniciar LSP" })

-- Format commands
vim.keymap.set("n", "<leader>cfd", vim.lsp.buf.format, { desc = "Format Document" })
vim.keymap.set("v", "<leader>cfd", vim.lsp.buf.format, { desc = "Format Selection" })

-- Format on save toggle
vim.keymap.set("n", "<leader>cft", function()
  local format_on_save = vim.b.format_on_save
  if format_on_save == nil then
    format_on_save = true
  end
  vim.b.format_on_save = not format_on_save
  print("Format on save: " .. tostring(not format_on_save))
end, { desc = "Toggle Format on Save" })
