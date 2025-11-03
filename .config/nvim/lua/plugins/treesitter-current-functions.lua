return {
  {
    "eckon/treesitter-current-functions",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-telescope/telescope.nvim" },
    init = function()
      vim.keymap.set("n", "mcf", ":GetCurrentFunctions<CR>")
    end,
  },
}
