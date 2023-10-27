return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
    opts = {
      window = {
        backdrop = 0.95,
        width = tonumber(vim.o.colorcolumn or "80") + 7,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          colorcolumn = "0",
          foldcolumn = "0",
          list = false,
        },
      },
      on_open = function(_)
        if not vim.diagnostic.is_disabled(0) then
          vim.b.restore_diagnostics = true
          vim.diagnostic.disable(0)
        end
      end,
      on_close = function()
        if vim.b.restore_diagnostics then
          vim.diagnostic.enable(0)
        end
      end,
    },
  },
}
