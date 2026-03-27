-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.root_spec = {
  function(buf)
    if vim.bo[buf].filetype ~= "vhdl" then
      return nil
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
      return nil
    end

    return vim.fs.root(name, { "vhdl_ls.toml", ".vhdl_ls.toml" })
  end,

  "lsp",
  { ".git", "lua" },
  "cwd",
}
