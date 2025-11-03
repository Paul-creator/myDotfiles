return {
  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- Set Skim as the PDF viewer
      vim.g.vimtex_view_method = "skim"
      -- Additional Skim-specific settings for forward/inverse search
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1 -- Skim will auto-focus when you open it

      -- -- pdf latex
      -- vim.g.vimtex_compiler_latexmk = {
      --   options = {
      --     "-pdf", -- <- this enables pdflatex
      --     "-shell-escape", -- if you need external tools
      --     "-file-line-error",
      --     '-pdflatex="pdflatex -interaction=nonstopmode"',
      --     "-interaction=nonstopmode",
      --     -- "-outdir=build",    -- optional output dir
      --   },

      -- vim.g.vimtex_compiler_method = "tectonic"
      -- vim.g.vimtex_compiler_tectonic = {
      --   executable = "tectonic",
      --   options = { "-X", "compile", "%f", "--synctex", "--keep-logs" },
      -- }

      -- vim.g.vimtex_compiler_method = "generic"
      -- vim.g.vimtex_compiler_generic = {
      --   command = "ls *.tex | entr -c tectonic /_ --synctex --keep-logs",
      -- }

      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-xelatex",
          "-latexoption=-shell-escape",
          "-file-line-error",
          "-interaction=nonstopmode",
          -- falls du ein outdir willst:
          -- "-outdir=build",
        },
      }
    end,
  },
}
