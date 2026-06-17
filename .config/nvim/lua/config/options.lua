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

-- Detect extensionless shell scripts by shebang
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, bufnr)
        -- Nur Dateien ohne Endung
        if vim.fn.fnamemodify(path, ":e") ~= "" then
          return nil
        end

        local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""

        -- bash: #!/bin/bash, #!/usr/bin/env bash, #!/usr/bin/env -S bash ...
        if first:match("^#!.*%f[%w]bash%f[%W]") then
          return "sh", function(buf)
            vim.b[buf].is_bash = 1
          end
        end

        -- POSIX sh
        if first:match("^#!.*%f[%w]sh%f[%W]") then
          return "sh"
        end

        -- zsh
        if first:match("^#!.*%f[%w]zsh%f[%W]") then
          return "zsh"
        end
      end,
      { priority = -math.huge },
    },
  },
})
