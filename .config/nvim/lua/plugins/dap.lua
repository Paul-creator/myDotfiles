return {
  {
    "mfussenegger/nvim-dap",
    init = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          -- You need to extend the classPath to list your dependencies.
          -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
          classPaths = {},

          -- If using multi-module projects, remove otherwise.
          -- projectName = "yourProjectName",

          javaExec = "/usr/bin/java",
          -- mainClass = "canteenplanner.app.CanteenApp",

          -- If using the JDK9+ module system, this needs to be extended
          -- `nvim-jdtls` would automatically populate this property
          modulePaths = {},
          name = "Launch",
          request = "launch",
          type = "java",
        },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "/opt/homebrew/bin/python3"
          end,
        },
      }
    end,
  },
}
