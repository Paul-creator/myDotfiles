if true then
  return {}
end

return {
  "github/copilot.vim", -- replace with the correct identifier for the Copilot plugin
  config = function()
    local opts = { noremap = true, silent = true }

    -- Function to toggle Copilot
    local function toggle_copilot()
      if vim.fn.exists(":Copilot disable") ~= 0 then
        vim.cmd("Copilot disable")
      else
        vim.cmd("Copilot enable")
      end
    end

    -- Set up the keymap
    vim.keymap.set("n", "mc", toggle_copilot, opts)
  end,
}
