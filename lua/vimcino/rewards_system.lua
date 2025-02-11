---@class vimcino.rewards
---@field key_count number number of keys pressed in a session
---@field config rewards.config | nil
local M = { key_count = 0, config = nil }

local stats = require("vimcino.stats")

--- Adds the rewards based on keys input
function M.add_reward()
  if math.fmod(M.key_count, M.config.goal) == 0 then
    if M.config.notify then
      vim.notify("Vimcino currency added!", 2)
    end
    stats.add_bank_value(M.config.value)
  end
end

function M.setup()
  M.config = require("vimcino.config").get_config("rewards")

  if M.config.enable then
    vim.on_key(function()
      M.key_count = M.key_count + 1
      M.add_reward()
    end)
  end
end

return M
