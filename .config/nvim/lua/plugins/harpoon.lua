return {
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      vim.api.nvim_set_keymap(
        "n",
        "<C-a>",
        [[:lua require("harpoon.mark").add_file()<CR>]],
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<C-e>",
        [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]],
        { noremap = true, silent = true }
      )

      vim.api.nvim_set_keymap(
        "n",
        "gh",
        [[:lua require("harpoon.ui").nav_file(1)<CR>]],
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "gj",
        [[:lua require("harpoon.ui").nav_file(2)<CR>]],
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "gk",
        [[:lua require("harpoon.ui").nav_file(3)<CR>]],
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "gl",
        [[:lua require("harpoon.ui").nav_file(4)<CR>]],
        { noremap = true, silent = true }
      )
    end,
  },
}
