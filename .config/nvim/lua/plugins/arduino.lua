return {
  "neovim/nvim-lspconfig",
  config = function()
    require("lspconfig").arduino_language_server.setup({
      cmd = {
        "arduino-language-server",
        "-cli",
        "arduino-cli",
        "-cli-config",
        -- path: arduino-cli config dump --verbose
        "/Users/paulkronegger/Library/Arduino15/arduino-cli.yaml",
        "-fqbn",
        "arduino:avr:uno",
      },
    })
  end,
}
