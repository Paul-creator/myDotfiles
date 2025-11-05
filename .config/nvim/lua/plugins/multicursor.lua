-- https://github.com/jake-stewart/multicursor.nvim?tab=readme-ov-file#example-config-lazynvim
return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set
    local wk = require("which-key")

    -- Which-key groups (new API)
    wk.add({
      { "<leader>m", group = "+multicursor" },
      { "<leader>m/", group = "+search" }, -- subgroup for search actions
      { "<leader>md", group = "+diagnostics" }, -- subgroup for diagnostics
    })

    -- ── Core line/skip actions (under <leader>m)
    set({ "n", "x" }, "<leader>m<up>", function()
      mc.lineAddCursor(-1)
    end, { desc = "Add cursor above" })
    set({ "n", "x" }, "<leader>m<down>", function()
      mc.lineAddCursor(1)
    end, { desc = "Add cursor below" })
    set({ "n", "x" }, "<leader>mK", function()
      mc.lineSkipCursor(-1)
    end, { desc = "Skip cursor above" })
    set({ "n", "x" }, "<leader>mJ", function()
      mc.lineSkipCursor(1)
    end, { desc = "Skip cursor below" })

    -- ── Match-based cursor creation
    set({ "n", "x" }, "<leader>mn", function()
      mc.matchAddCursor(1)
    end, { desc = "Add next match cursor" })
    set({ "n", "x" }, "<leader>mN", function()
      mc.matchAddCursor(-1)
    end, { desc = "Add previous match cursor" })
    set({ "n", "x" }, "<leader>ms", function()
      mc.matchSkipCursor(1)
    end, { desc = "Skip next match cursor" })
    set({ "n", "x" }, "<leader>mS", function()
      mc.matchSkipCursor(-1)
    end, { desc = "Skip previous match cursor" })

    -- ── Mouse control (kept global)
    set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Add/remove cursor (Ctrl+Click)" })
    set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Drag cursors (Ctrl+Drag)" })
    set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Release drag cursors" })

    -- ── Toggle multicursor mode (global)
    set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle multicursor mode" })

    -- ── Layer-only mappings (active when multiple cursors exist)
    mc.addKeymapLayer(function(layerSet)
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)
      layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor) -- delete main cursor

      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- ── Advanced Actions (all under <leader>m...)
    -- Operator (moved OFF the bare <leader>m to prevent shadowing)
    set({ "n", "x" }, "<leader>mo", mc.operator, { desc = "Multicursor operator (create cursors in range)" })

    -- Duplicate / Align / Restore / All matches / Transpose
    set({ "n", "x" }, "<leader>m<C-q>", mc.duplicateCursors, { desc = "Duplicate all cursors" })
    set("n", "<leader>ma", mc.alignCursors, { desc = "Align cursors vertically" })
    set("n", "<leader>mr", mc.restoreCursors, { desc = "Restore last cleared cursors" })
    set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Add cursors for all matches in buffer" })
    set("x", "<leader>mt", function()
      mc.transposeCursors(1)
    end, { desc = "Rotate text between cursors (forward)" })
    set("x", "<leader>mT", function()
      mc.transposeCursors(-1)
    end, { desc = "Rotate text between cursors (backward)" })

    -- Visual block-like insert/append (kept on I/A, but you can also mirror them)
    set("x", "I", mc.insertVisual, { desc = "Insert before each selection line" })
    set("x", "A", mc.appendVisual, { desc = "Append after each selection line" })
    -- Optional mirrored under <leader>m:
    -- set("x", "<leader>mI", mc.insertVisual, { desc = "Insert before each selection line" })
    -- set("x", "<leader>mA", mc.appendVisual, { desc = "Append after each selection line" })

    -- Sequences
    set({ "n", "x" }, "<leader>m+", mc.sequenceIncrement, { desc = "Increment sequence across cursors" })
    set({ "n", "x" }, "<leader>m-", mc.sequenceDecrement, { desc = "Decrement sequence across cursors" })
    -- (Original g<C-a>/g<C-x> kept too)
    set({ "n", "x" }, "g<c-a>", mc.sequenceIncrement, { desc = "Increment sequence across cursors" })
    set({ "n", "x" }, "g<c-x>", mc.sequenceDecrement, { desc = "Decrement sequence across cursors" })

    -- Search subgroup under <leader>m/
    set("n", "<leader>m/n", function()
      mc.searchAddCursor(1)
    end, { desc = "Add cursor at next search match" })
    set("n", "<leader>m/N", function()
      mc.searchAddCursor(-1)
    end, { desc = "Add cursor at previous search match" })
    set("n", "<leader>m/s", function()
      mc.searchSkipCursor(1)
    end, { desc = "Skip next search match" })
    set("n", "<leader>m/S", function()
      mc.searchSkipCursor(-1)
    end, { desc = "Skip previous search match" })
    set("n", "<leader>m/A", mc.searchAllAddCursors, { desc = "Add cursors at all search matches" })

    -- Diagnostics subgroup under <leader>md
    set({ "n", "x" }, "<leader>mdn", function()
      mc.diagnosticAddCursor(1)
    end, { desc = "Add cursor at next diagnostic" })
    set({ "n", "x" }, "<leader>mdp", function()
      mc.diagnosticAddCursor(-1)
    end, { desc = "Add cursor at previous diagnostic" })
    set({ "n", "x" }, "<leader>mdN", function()
      mc.diagnosticSkipCursor(1)
    end, { desc = "Skip next diagnostic" })
    set({ "n", "x" }, "<leader>mdP", function()
      mc.diagnosticSkipCursor(-1)
    end, { desc = "Skip previous diagnostic" })
    set({ "n", "x" }, "<leader>mdA", function()
      mc.diagnosticMatchCursors({ severity = vim.diagnostic.severity.ERROR })
    end, { desc = "Add cursors for all ERROR diagnostics in range" })

    -- Non-leader operator (kept): gaip adds cursor on each line of a paragraph
    set("n", "ga", mc.addCursorOperator, { desc = "Add cursor to each line in paragraph (operator)" })

    -- Highlights
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
