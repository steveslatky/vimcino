---@class vimcino
local M = {}

local Config = require("vimcino.config")
local Selector = require("vimcino.selector")
local Stats = require("vimcino.stats")

local function create_commands()
  vim.api.nvim_create_user_command("Vimcino", function()
    Selector.show()
  end, {})

  vim.api.nvim_create_user_command("VimcinoStats", function()
    Stats.show_stats()
  end, {})
end

function M.setup(opts)
  Config.setup(opts)
  Stats.setup()
  require("vimcino.rewards_system").setup()
  create_commands()
end

return M
