return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tailwindcss = {},
      matlab_ls = {
        -- capabilities = capabilities,
        cmd = { "matlab-language-server", "--stdio" },
        filetypes = { "matlab" },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.find_git_ancestor(fname) or util.root_pattern("*.m")(fname) or vim.fn.getcwd()
        end,
        settings = {
          MATLAB = {
            indexWorkspace = true,
            installPath = "/Applications/$(ls /Applications | grep -i matlab)", -- Update this path to your MATLAB installation
            matlabConnectionTiming = "onStart",
            telemetry = false,
          },
        },
        single_file_support = true,
      },
    },
    texlab = {
      settings = {
        texlab = {
          build = {
            executable = "latexmk", -- Use latexmk for building
            args = {
              "-pdf",
              "-shell-escape",
              "-n18", -- Suppress warning number 18 for quotes "
              "-interaction=nonstopmode",
              "-synctex=1",
              "%f",
            },
            onSave = true, -- Build on save
          },
          forwardSearch = {
            executable = "open", -- Use `open` to launch Skim
            args = {
              "-a",
              "Skim", -- Open with Skim
              "--args",
              "%p",
              "-g",
              "-r",
              "%l:1:%f", -- SyncTeX forward search arguments
            },
          },
          chktex = {
            onOpenAndSave = true, -- Enable linting
            extraArgs = { "-n18" }, -- Suppress warning number 18 for quotes "
          },
          -- diagnosticsDelay = 300,
          formatterLineLength = 80,
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = true,
          },
        },
      },
    },
  },
}
