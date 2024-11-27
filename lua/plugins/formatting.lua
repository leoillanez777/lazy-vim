return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cFL",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  init = function()
    -- Install the conform formatter on VeryLazy
    LazyVim.on_very_lazy(function()
      LazyVim.format.register({
        name = "conform.nvim",
        priority = 100,
        primary = true,
        format = function(buf)
          require("conform").format({ bufnr = buf })
        end,
        sources = function(buf)
          local ret = require("conform").list_formatters(buf)
          return vim.tbl_map(function(v)
            return v.name
          end, ret)
        end,
      })
    end)
  end,
  opts = function()
    ---@type conform.setupOpts
    return {
      -- Define el formato predeterminado
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "black", "isort" },
        ["_"] = { "trim_whitespace" },
      },
      -- Configuraciones de formatadores específicos
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
            lang_to_ext = {
              bash = "sh",
              c_sharp = "cs",
              elixir = "exs",
              javascript = "js",
              julia = "jl",
              latex = "tex",
              markdown = "md",
              python = "py",
              ruby = "rb",
              rust = "rs",
              teal = "tl",
              typescript = "ts",
            },
            -- Map of treesitter language to formatters to use
            -- (defaults to the value from formatters_by_ft)
            lang_to_formatters = {},
          },
        },
        prettier = {
          -- Usar .prettierrc si existe
          prepend_args = { "--config-precedence", "prefer-file" },
        },
        csharpier = {
          prepend_args = { "--write-stdout", "--indent-size", "2" },
        },
        -- Configuración para stylua
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        -- Configuración para black
        black = {
          prepend_args = { "--line-length", "88" },
        },
        -- Configuración para isort
        isort = {
          prepend_args = { "--profile", "black" },
        },
        -- Configuración para shfmt
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    }
  end,
}
