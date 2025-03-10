---@class vimcino
local M = {}
Log = require("stack.log")

local Selector = require("vimcino.selector")
local Stats = require("vimcino.stats")

--- Creates all commands
local function create_commands()
  vim.api.nvim_create_user_command("Vimcino", function(opts)
    if opts.args and opts.args ~= "" then
      Selector.start_game(opts.args)
    else
      Selector.show()
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("VimcinoStats", function()
    Stats.show_stats()
  end, {})
end

function M.setup(opts)
  require("vimcino.config").setup(opts)
  require("vimcino.stats").setup()
  require("vimcino.rewards_system").setup()
  create_commands()
end

return M
