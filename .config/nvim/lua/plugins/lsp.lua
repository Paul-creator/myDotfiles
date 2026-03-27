-- important mason install vhdl_ls did not work consistently.
-- this doing a manual install using crates.io (cargo) !important
-- vhdl libs must be be pasted into same folder like vhdl_ls
-- https://github.com/VHDL-LS/rust_hdl/tree/master/vhdl_libraries

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          vhd = "vhdl",
        },
      })

      vim.lsp.config("vhdl_ls", {
        cmd = { "/bin/bash", "/Users/paulkronegger/.local/bin/vhdl_ls_wrapper" },
        filetypes = { "vhdl" },
        root_markers = { "vhdl_ls.toml", ".vhdl_ls.toml" },
        single_file_support = false,
      })

      vim.lsp.enable("vhdl_ls")
    end,
  },
}
