---@class vimcino.util.hl
---@field config vimcino.config
local M = {}
M.config = require("vimcino.config").get_config("hl")

function M.setup() end

return M
