---@class config.autocommand
---@field [1] string|string[]
---@field [2] string|fun()
---@field desc? string
---@field pattern? string|string[]

---@type config.autocommand[]
local autocommands = {
  {
    { "FocusGained", "TermClose", "TermLeave" },
    "checktime",
    desc = "Reload file if it was modified in the background",
  },

  -- stylua: ignore
  { "TextYankPost", function() vim.highlight.on_yank() end, desc = "Highlight on yank" },

  {
    "VimResized",
    function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
    desc = "Resize splits on window resize",
  },

  {
    "BufReadPost",
    function(arg)
      local exclude = { "gitcommit" }
      local buf = arg.buf
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
        return
      end

      vim.b[buf].last_loc = true
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
    desc = "Go to last line of code when opening a buffer",
  },

  {
    "BufWritePre",
    function(arg)
      if arg.match:match("^%w%w+://") then
        return
      end

      local file = vim.uv.fs_realpath(arg.match) or arg.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
    desc = "Auto create parent directories when they don't exist",
  },

  {
    "VimLeave",
    "set guicursor= | call chansend(v:stderr, '\x1b[ q')",
    desc = "Restore default cursor on exit",
  },

  {
    "FileType",
    function(arg)
      vim.bo[arg.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = arg.buf, desc = "Close buffer" })
    end,
    pattern = {
      "checkhealth",
      "help",
      "qf",
      "query",
    },
    desc = "Close with q",
  },

  {
    { "BufNewFile", "BufRead" },
    'setlocal noswapfile nobackup noundofile shada=""',
    pattern = "/dev/shm/gopass*",
    desc = "Do not cache data for gopass secrets",
  },

  {
    "TermOpen",
    "setlocal nonumber norelativenumber signcolumn=no",
    desc = "Hide numbers and signcolumn in terminal buffers",
  },
}

---@param autocommand config.autocommand
vim.iter(autocommands):each(function(autocommand)
  ---@type vim.api.keyset.create_autocmd
  local opts = {
    desc = autocommand.desc,
    pattern = autocommand.pattern,
  }
  local action = autocommand[2]
  if type(action) == "string" then
    opts.command = action
  else
    opts.callback = action
  end

  vim.api.nvim_create_autocmd(autocommand[1], opts)
end)
