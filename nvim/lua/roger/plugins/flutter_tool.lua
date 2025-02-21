return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local keymaps = require("roger.core.keymaps")
    keymaps.flutter()

    local flutter_tools = require("flutter-tools")
    local telescope = require("telescope")

    flutter_tools.setup({
      flutter_path = nil,
      flutter_lookup_cmd = nil,
      fvm = false,
      widget_guides = { enabled = true },
      closing_tags = {
        highlight = "FlutterClosingTag", -- highlight for the closing tag
        prefix = ">", -- character to use for close tag e.g. > Widget
        priority = 10, -- priority of virtual text in current line
        -- consider to configure this when there is a possibility of multiple virtual text items in one line
        -- see `priority` option in |:help nvim_buf_set_extmark| for more info
        enabled = true, -- set to false to disable
      },
      dev_tools = {
        autostart = true, -- autostart devtools server if not detected
        auto_open_browser = true, -- Automatically opens devtools in the browser
      },
      lsp = {
        settings = {
          showtodos = true,
          completefunctioncalls = true,
          analysisexcludedfolders = {
            vim.fn.expand("$Home/.pub-cache"),
          },
          renamefileswithclasses = "prompt",
          updateimportsonrename = true,
          enablesnippets = true,
        },
      },
      debugger = {
        enabled = false, -- TODO: Just For Now
        run_via_dap = true,
        exception_breakpoints = {},
        register_configurations = function(paths)
          local dap = require("dap")
          -- See also: https://github.com/akinsho/flutter-tools.nvim/pull/292
          dap.adapters.dart = {
            type = "executable",
            command = paths.flutter_bin,
            args = { "debug-adapter" },
          }
          dap.configurations.dart = {}
          require("dap.ext.vscode").load_launchjs()
        end,
      },
    })

    telescope.load_extension("flutter")
  end,
}
