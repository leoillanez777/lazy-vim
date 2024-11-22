local logo = [[
⠀⠀⠀⠀⣀⣤⣤⣶⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⣶⣦⣤⣀⠀⠀⠀⠀⠀
⢀⣴⣶⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⣧⣼⠀⠀⠀⠀⣀⣴⣿⣿⣿⣿⣿⣿⣷⣦⣄⡀
⠀⠀⠀⠈⠉⠛⣿⣿⣿⣿⣿⣷⣦⣀⢸⣿⣿⡇⣀⣤⣿⣯⣿⣿⣿⣿⠟⠋⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
>>> Leo Illanez 🧉 <<<
 **       ********   *******         *******   ******** **      **
/**      /**/////   **/////**       /**////** /**///// /**     /**
/**      /**       **     //**      /**    /**/**      /**     /**
/**      /******* /**      /**      /**    /**/******* //**    **
/**      /**////  /**      /**      /**    /**/**////   //**  **
/**      /**      //**     **       /**    ** /**        //****
/********/******** //*******        /*******  /********   //**
//////// ////////   ///////         ///////   ////////     //
]]
logo = string.rep("\n", 8) .. logo .. "\n\n"

return {
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          header = vim.split(logo, "\n"),
          week_header = {
            enable = true,
          },
          shortcut = {
            { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
            {
              icon = " ",
              icon_hl = "@variable",
              desc = "Files",
              group = "Label",
              action = "Telescope find_files",
              key = "f",
            },
            {
              desc = " Apps",
              group = "DiagnosticHint",
              action = "Telescope app",
              key = "a",
            },
            {
              desc = " dotfiles",
              group = "Number",
              action = "Telescope dotfiles",
              key = "d",
            },
          },
          packages = { enable = true },
          project = {
            enable = true,
            limit = 8,
            icon = "",
            label = "",
            action = "Telescope find_files cwd=",
          },
          mru = {
            enable = true,
            limit = 10,
            icon = "",
            label = "",
          },
        },
      })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
