-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- go to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- reveal in finder
vim.keymap.set("n", "O", function()
  local picker = vim.tbl_filter(function(p)
    return not p.closed
  end, Snacks.picker.get({ tab = true }))[1]
  if not picker then
    return
  end

  local items = picker:selected({ fallback = true })

  for _, item in ipairs(items) do
    local path = vim.fn.fnamemodify(item.file or item.text, ":p")
    vim.fn.jobstart({ "open", "-R", path }, { detach = true })
  end
end)

-- save with(out) formatting
vim.keymap.set("n", "<leader>fs", "<cmd>write<cr>", {
  desc = "Save file",
})
vim.keymap.set("n", "<leader>fS", "<cmd>noautocmd write<cr>", {
  desc = "Save file without formatting",
})
