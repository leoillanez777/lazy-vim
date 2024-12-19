return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vue", "css", "typescript", "javascript" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        tsserver = { enabled = false },
        ts_ls = { enabled = false },
        eslint = { enabled = false },
        volar = {
          enabled = true,
          filetypes = { "vue", "css", "typescript", "javascript", "json" },
          root_dir = require("lspconfig").util.root_pattern("vite.config.js"),
          init_options = {
            vue = {
              hybridMode = true,
            },
            typescript = {
              tsdk = vim.fn.expand(
                "$HOME/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
              ),
            },
            languageFeatures = {
              implementation = true,
              references = true,
              definition = true,
              typeDefinition = true,
              callHierarchy = true,
              hover = true,
              rename = true,
              renameFileRefactoring = true,
              signatureHelp = true,
              codeAction = true,
              workspaceSymbol = true,
              diagnostics = true, -- Habilita diagnósticos
              semanticTokens = true, -- Habilita tokens semánticos
              completion = {
                defaultTagNameCase = "both",
                defaultAttrNameCase = "kebabCase",
              },
            },
          },
          -- Configuración para encontrar el SDK de TypeScript
          on_new_config = function(new_config, new_root_dir)
            local lib_path = vim.fs.find("node_modules/typescript/lib", { path = new_root_dir, upward = true })[1]
            if lib_path then
              new_config.init_options.typescript.tsdk = lib_path
            end

            -- Configuración específica para Vue
            new_config.init_options.vue = {
              hybridMode = true,
              serverMode = true,
              diagnosticModel = "pull", -- Modelo de diagnóstico más eficiente
            }
          end,
        },
        vtsls = {
          enabled = false,
        },
      },
      setup = {
        volar = function()
          return true
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      table.insert(opts.servers.vtsls.filetypes, "vue")
      LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@vue/typescript-plugin",
          location = LazyVim.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
          languages = { "vue" },
          configNamespace = "typescript",
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function()
      local null_ls = require("null-ls")
      return {
        sources = {
          null_ls.builtins.code_actions.eslint,
          null_ls.builtins.formatting.prettier,
        },
      }
    end,
  },
}
