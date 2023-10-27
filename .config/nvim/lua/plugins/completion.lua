return {
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    opts = {
      history = true,
      region_check_events = "CursorHold,InsertLeave,InsertEnter",
      delete_check_events = "TextChanged,InsertEnter",
    },
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = {
      {
        "nvim-lspconfig",
        opts = function(_, opts)
          return vim.tbl_deep_extend("force", opts, {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "LuaSnip",
    },
    opts = function(_, _)
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local luasnip = require("luasnip")

      ---@diagnostic disable-next-line: missing-fields
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline({
          ["<cr>"] = cmp.mapping({
            c = cmp.mapping.confirm({ select = false }),
          }),
        }),

        sources = {
          { name = "buffer" },
        },
      })

      ---@diagnostic disable-next-line: missing-fields
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<cr>"] = cmp.mapping({
            c = cmp.mapping.confirm({ select = false }),
          }),
        }),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })

      return {
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menuone,noselect,preview",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<cr>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          }),

          ["<c-b>"] = cmp.mapping.scroll_docs(-4),
          ["<c-f>"] = cmp.mapping.scroll_docs(4),
          ["<c-e>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "emoji" },
          { name = "buffer", keyword_length = 5 },
          { name = "path" },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },

          format = function(entry, item)
            local icons = require("config").icons.kinds
            item.kind = icons[item.kind]
            local sources = {
              nvim_lsp = "LSP",
              nvim_lua = "Lua",
              luasnip = "Snippet",
              buffer = "Buffer",
              path = "Path",
            }
            item.menu = sources[entry.source.name]
            return item
          end,
        },
        experimental = {
          ghost_text = true,
          hl_group = "CmpGhostText",
        },
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require("cmp").setup(opts)
    end,
  },
}
