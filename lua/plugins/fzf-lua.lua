return {
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    config = function()
      -- Set transparent background for all fzf-lua components
      vim.api.nvim_set_hl(0, "FzfLuaBackdrop", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaTitle", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaPreviewNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FzfLuaPreviewTitle", { bg = "NONE" })

      require("fzf-lua").setup({
        -- Configure fzf-lua colorscheme
        fzf_colors = {
          -- Built-in colorschemes: true (auto), false (no colors), or table with custom colors
          -- Available built-in schemes: "hl", "base16", "auto", "16"
          true, -- Enable auto colorscheme detection based on your Neovim colorscheme

          -- OR use specific colorscheme:
          -- ["fg"] = { "fg", "Normal" },
          -- ["bg"] = { "bg", "Normal" },
          -- ["hl"] = { "fg", "Comment" },
          -- ["fg+"] = { "fg", "CursorLine" },
          -- ["bg+"] = { "bg", "CursorLine" },
          -- ["hl+"] = { "fg", "Statement" },
          -- ["info"] = { "fg", "PreProc" },
          -- ["prompt"] = { "fg", "Conditional" },
          -- ["pointer"] = { "fg", "Exception" },
          -- ["marker"] = { "fg", "Keyword" },
          -- ["spinner"] = { "fg", "Label" },
          -- ["header"] = { "fg", "Comment" },
        },

        -- You can also use predefined colorschemes:
        -- colorschemes = {
        --   ["scheme_name"] = {
        --     -- your color definitions here
        --   }
        -- },

        -- Optional: Set fzf options for better integration
        fzf_opts = {
          ["--ansi"] = true,
          ["--info"] = "inline",
          ["--layout"] = "reverse",
          ["--height"] = "100%",
          ["--border"] = "rounded",
        },

        -- Window options
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.50,
          border = "rounded",
          backdrop = "none",
          preview = {
            default = "bat",
          },
        },
      })
    end,
  },
}
