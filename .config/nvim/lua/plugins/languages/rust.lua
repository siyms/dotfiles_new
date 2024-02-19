return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "ron",
        "rust",
      })
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^3",
    ft = { "rust" },
  },
}
