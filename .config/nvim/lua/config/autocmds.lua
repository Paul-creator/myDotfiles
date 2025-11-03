-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local lspconfig = require("lspconfig")
lspconfig.efm.setup({
  init_options = { documentFormatting = true },
  filetypes = { "tex" },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      tex = {
        {
          -- Format command: -w (in-place) und -m (kein Backup, sofern unterstützt)
          formatCommand = "latexindent -w -m",
          formatStdin = false, -- latexindent erwartet eine Datei, nicht stdin
        },
      },
    },
  },
})

-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.tex",
--   callback = function()
--     local filepath = vim.fn.expand("%:p")
--     vim.fn.jobstart({ "tex-fmt", filepath }, {
--       on_exit = function(_, exit_code)
--         vim.schedule(function()
--           if exit_code == 0 then
--             -- Reload the file to show changes
--             vim.cmd("edit")
--           else
--             print("tex-fmt failed with exit code " .. exit_code)
--           end
--         end)
--       end,
--     })
--   end,
-- })
