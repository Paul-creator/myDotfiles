return {
  {
    "mbbill/undotree",
    init = function()
      vim.keymap.set("n", "mu", ":UndotreeToggle<CR>")
    end,
  },
}
