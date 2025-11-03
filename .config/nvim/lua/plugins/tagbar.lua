return {
  {
    "preservim/tagbar",
    init = function()
      vim.keymap.set("n", "mt", ":TagbarToggle<CR>")
    end,
  },
}
