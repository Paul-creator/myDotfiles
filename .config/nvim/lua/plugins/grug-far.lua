return {
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup({
        search_options = {
          -- Enable multiline search
          multiline = true,
        },
      })
    end,
  },
}
