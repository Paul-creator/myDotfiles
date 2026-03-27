-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- VHDL Formatting
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "vhdl" then
      return
    end

    local file = args.file
    vim.fn.system({
      "emacs",
      "--batch",
      file,
      "--eval",
      "(progn (require 'vhdl-mode) (vhdl-beautify-buffer) (save-buffer))",
    })

    vim.cmd("edit")
  end,
})

-- vim.lsp.config("vhdl_ls", {
--   cmd = { "/bin/bash", "/Users/paulkronegger/.local/bin/vhdl_ls_wrapper" },
--   filetypes = { "vhdl" },
--   root_markers = { "vhdl_ls.toml", ".vhdl_ls.toml" },
--   single_file_support = false,
-- })
