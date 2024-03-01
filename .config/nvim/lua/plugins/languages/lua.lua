---@class lsp.lua_ls.config.settings
---@field format? { enabled?: boolean}
---@field Lua? { workspace?: { checkThirdParty?: boolean } }

---@class lsp.lua_ls.config: plugins.lspconfig.server.opts
---@field settings? lsp.lua_ls.config.settings

---@type LazyPluginSpec[]
return {
  {
    "nvim-treesitter",
    ---@param opts plugins.treesitter.config
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "lua",
      })
    end,
  },

  {
    "nvim-lspconfig",
    ---@type plugins.lspconfig.config
    opts = {
      servers = {
        ---@type lsp.lua_ls.config
        lua_ls = {
          settings = {
            format = { enable = false },
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
            },
          },
        },
      },
    },
  },

  {
    "conform.nvim",
    ---@type plugins.conform.config
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
