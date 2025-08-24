return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          init_options = {
            provideFormatter = true,
          },
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
            scss = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            return capabilities
          end)(),
        },
      },
    },
  },
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    -- optionally, override the default options:
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },
}
