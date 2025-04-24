return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    -- add any opts here
    provider = "gemini",
    openai = {
      endpoint = "http://localhost:11434/v1/",
      model = "llama3.1:8b-instruct-q8_0",
      timeout = 60000,
      temperature = 0,
      max_tokens = 4096,
      disable_tools = true,
    },
    gemini = {
      -- @see https://ai.google.dev/gemini-api/docs/models/gemini
      model = "gemini-2.5-pro-exp-03-25",
      timeout = 30000, -- timeout in milliseconds
      temperature = 0, -- adjust if needed
      max_tokens = 4096,
    },
    ollama = {
      model = "llama-13B",
    },
    chat = {
      open_chat_on_startup = false,
      open_floating_window = true,
      window_width = 0.8, -- 80% de la pantalla
      window_height = 0.8, -- 80% de la pantalla
    },
    keymaps = {
      toggle = "<leader>ai", -- Tecla para abrir/cerrar Avante
      exec_line = "<leader>al", -- Ejecutar la línea actual
      exec_selection = "<leader>as", -- Ejecutar selección
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
