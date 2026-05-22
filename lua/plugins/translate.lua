return {
  "uga-rosa/translate.nvim",
  cmd = "Translate",
  keys = {
    { "<leader>te", ":Translate EN<CR>", mode = { "n", "v" }, desc = "Translate to English" },
    { "<leader>ts", ":Translate ES<CR>", mode = { "n", "v" }, desc = "Translate to Spanish" },
    { "<leader>tE", ":Translate EN -output=register -register=+<CR>", mode = { "n", "v" }, desc = "Translate EN → clipboard" },
    { "<leader>tS", ":Translate ES -output=register -register=+<CR>", mode = { "n", "v" }, desc = "Translate ES → clipboard" },
    { "<leader>tr", ":Translate EN -output=replace<CR>", mode = "v", desc = "Translate EN (replace selection)" },
    { "<leader>tR", ":Translate ES -output=replace<CR>", mode = "v", desc = "Translate ES (replace selection)" },
    { "<leader>tf", ":Translate EN -output=floating<CR>", mode = { "n", "v" }, desc = "Translate EN (floating)" },
  },
  opts = {
    default = {
      command = "translate_shell",
    },
    preset = {
      output = {
        split = { append = true },
      },
    },
  },
}
