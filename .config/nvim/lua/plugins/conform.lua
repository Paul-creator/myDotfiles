return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters.vhdl_emacs = {
        inherit = false,
        command = "emacs",
        args = {
          "--batch",
          "$FILENAME",
          "--eval",
          "(progn (require 'vhdl-mode) (vhdl-mode) (vhdl-beautify-buffer) (save-buffer))",
        },
        stdin = false,
      }

      opts.formatters_by_ft.vhdl = {
        "vhdl_emacs",
        lsp_format = "never",
      }
    end,
  },
}
