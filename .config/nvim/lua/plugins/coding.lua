return {
  { "rafamadriz/friendly-snippets", enabled = false },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- attach cmp source whenever copilot attaches
      -- fixes lazy-loading issues with the copilot cmp source
      require("lazyvim.util").on_attach(function(client)
        if client.name == "copilot" then
          copilot_cmp._on_insert_enter({})
        end
      end)
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "zbirenbaum/copilot-cmp",
      "L3MON4D3/LuaSnip",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      return vim.tbl_deep_extend("force", opts, {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          documentation = {
            winhighlight = "NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder",
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<c-b>"] = cmp.mapping.scroll_docs(-4),
          ["<c-f>"] = cmp.mapping.scroll_docs(4),
          ["<c-e>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm({ select = false }),
          ---@diagnostic disable-next-line: missing-parameter
          ["<c-space>"] = cmp.mapping.complete(),
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
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
        }),
        sources = cmp.config.sources({
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "emoji" },
          { name = "buffer", keyword_length = 5 },
        }),
        formatting = {
          format = function(_, item)
            local icons = require("lazyvim.config").icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.move",
    keys = function(plugin, _)
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      return {
        { opts.mappings.left, mode = "v" },
        { opts.mappings.right, mode = "v" },
        { opts.mappings.down, mode = "v" },
        { opts.mappings.up, mode = "v" },

        opts.mappings.line_left,
        opts.mappings.line_right,
        opts.mappings.line_down,
        opts.mappings.line_up,
      }
    end,
    opts = {
      mappings = {
        -- Visual selection mappings
        left = "<a-h>",
        right = "<a-l>",
        down = "<a-j>",
        up = "<a-k>",

        -- Normal mode mappings
        line_left = "<a-h>",
        line_right = "<a-l>",
        line_down = "<a-j>",
        line_up = "<a-k>",
      },
    },
    config = function(_, opts)
      require("mini.move").setup(opts)
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    event = "BufReadPre",
    config = true,
  },
  {
    "echasnovski/mini.pairs",
    enabled = false,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        mappings = {
          ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\%(][^%)%a'\"]" },
          ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\%[][^%]%a'\"]" },
          ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\%{][^%}%a'\"]" },

          ["'"] = { action = "open", pair = "''", neigh_pattern = "[^%S][^%a]" },
          ['"'] = { action = "open", pair = '""', neigh_pattern = "[^%S][^%a]" },
        },
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "BufReadPre",
    opts = {
      check_ts = true,
      ts_config = { java = false },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
  },
  {
    "echasnovski/mini.comment",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    keys = {
      "gcc",
      "gc",
      { "<c-/>", "gcc", mode = "n", remap = true },
      { "<c-/>", "gc", mode = "v", remap = true },
    },
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        options = {
          ignore_blank_line = true,
        },
      })
    end,
  },
}
