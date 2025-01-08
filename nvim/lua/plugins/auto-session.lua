return {
  "rmagatti/auto-session",
  config = function()
    local keymaps = require("config.keymaps")
    keymaps.auto_session()

    local auto_session = require("auto-session")
    auto_session.setup({
      auto_restore = false,
      auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })
  end,
}
