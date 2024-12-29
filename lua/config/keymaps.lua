-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function insert_accent(char)
  return function()
    vim.api.nvim_input(char)
  end
end

local map = LazyVim.safe_keymap_set

map("i", "]a", insert_accent("á"), { desc = "Insertar á" })
map("i", "]e", insert_accent("é"), { desc = "Insertar é" })
map("i", "]i", insert_accent("í"), { desc = "Insertar í" })
map("i", "]o", insert_accent("ó"), { desc = "Insertar ó" })
map("i", "]u", insert_accent("ú"), { desc = "Insertar ú" })
map("i", "]n", insert_accent("ñ"), { desc = "Insertar ñ" })
map("i", "]A", insert_accent("Á"), { desc = "Insertar Á" })
map("i", "]E", insert_accent("É"), { desc = "Insertar É" })
map("i", "]I", insert_accent("Í"), { desc = "Insertar Í" })
map("i", "]O", insert_accent("Ó"), { desc = "Insertar Ó" })
map("i", "]U", insert_accent("Ú"), { desc = "Insertar Ú" })
map("i", "]N", insert_accent("Ñ"), { desc = "Insertar Ñ" })

-- Select text in insert mode
map("i", "<C-h>", "<Esc>vb", { desc = "Seleccionar palabra anterior" })
map("i", "<C-l>", "<Esc>ve", { desc = "Seleccionar siguiente palabra" })
map("i", "<S-Tab>", "<Esc>vec", { desc = "Seleccionar y editar siguiente palabra" })
-- Go to end the line in insert mode
map("i", "<C-e>", "<Esc>l$a", { desc = "Mover cursor al final de la línea" })
-- Go to beginning of line in insert mode
map("i", "<C-w>", "<Esc>I", { desc = "Mover cursor al principio de la línea" })

local wk = require("which-key")
wk.add({
  { "<leader>F", group = " Conflictos", icon = "" },
  { "<leader>d", group = "Debbuger", icon = "" },
  { "<leader>cf", group = "Format", icon = "" },
  { "<leader>a", group = "AI (codeium, avante)", icon = "" },
})

-- Codeium
map("n", "<leader>ac", "<cmd>Codeium Chat<cr>", { desc = "󰈌 Codeium Chat" })
map("n", "<leader>aA", "<cmd>Codeium Auth<cr>", { desc = "󰈌 Codeium Auth" })

-- Git Conflict
map("n", "<leader>Fo", "<cmd>GitConflictChooseOurs<cr>", { desc = " Escoger los cambios actuales" })
map("n", "<leader>Ft", "<cmd>GitConflictChooseTheirs<cr>", { desc = " Escoger los cambios entrantes" })
map("n", "<leader>Fb", "<cmd>GitConflictChooseBoth<cr>", { desc = " Escoger ambos cambios" })
map("n", "<leader>Fe", "<cmd>GitConflictChooseNone<cr>", { desc = "󰝾 Escoger ninguno de los cambios" })
map("n", "<leader>Fn", "<cmd>GitConflictNextConflict<cr>", { desc = " Siguiente conflicto" })
map("n", "<leader>FN", "<cmd>GitConflictPrevConflict<cr>", { desc = " Conflicto anterior" })
map("n", "<leader>Fl", "<cmd>GitConflictListQf<cr>", { desc = " Lista de conflictos" })
map("n", "<leader>Fa", "<cmd>Gwrite<cr>", { desc = " Grabar Cambios" })

-- Agregar una opción para ejecutar :LspRestart con <leader>x -> r, con icono de reinicio 
map("n", "<leader>xr", "<cmd>LspRestart<cr>", { desc = " Reiniciar LSP" })
map("n", "<leader>xR", "<cmd>edit ~/.local/state/nvim/lsp.log<cr>", { desc = "Ver log LSP" })

-- Format commands
map("n", "<leader>cfd", vim.lsp.buf.format, { desc = "Format Document" })
map("v", "<leader>cfd", vim.lsp.buf.format, { desc = "Format Selection" })

-- Format on save toggle
map("n", "<leader>cft", function()
  local format_on_save = vim.b.format_on_save
  if format_on_save == nil then
    format_on_save = true
  end
  vim.b.format_on_save = not format_on_save
  print("Format on save: " .. tostring(not format_on_save))
end, { desc = "Toggle Format on Save" })
