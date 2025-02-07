local M = {}

---@class blackjack.Config
---@field number_of_decks integer Number of decks to use in the game

---@class deathroll.Config
---@field starting_number number Number you start the roll with
---@field computer_start boolean If true computer will start the game

---@class vimcino.Config
---@field stats_file? string Path to the statistics file
---@field blackjack blackjack.Config Blackjack game configuration
---@field deathroll deathroll.Config Blackjack game configuration

-- Private module state
local Options = {}

-- Default configuration with documentation
---@type vimcino.Config
M.default_config = {
  stats_file = nil,
  blackjack = {
    number_of_decks = 1,
  },
  deathroll = {
    starting_number = 1000,
    computer_start = false,
  },
}

-- Validate the configuration
---@param config vimcino.Config
---@return boolean is_valid
---@return string? error_message
local function validate_config(config)
  if config.blackjack and type(config.blackjack.number_of_decks) ~= "number" then
    return false, "blackjack.number_of_decks must be a number"
  end

  if config.stats_file and type(config.stats_file) ~= "string" then
    return false, "stats_file must be a string"
  end

  return true
end

-- Update the default config
---@param config? vimcino.Config
---@return vimcino.Config
local function extend(config)
  if not config then
    return vim.deepcopy(M.default_config)
  end
  return vim.tbl_deep_extend("force", vim.deepcopy(M.default_config), config)
end

-- Get the current configuration
---@return vimcino.Config
function M.get_config()
  return vim.deepcopy(Options)
end

-- Setup options
---@param opts? vimcino.Config User defined options
---@return vimcino.Config Options used by the application
---@error "Invalid configuration" when the configuration is invalid
function M.setup(opts)
  local config = extend(opts)

  -- Validate configuration
  local is_valid, error_message = validate_config(config)
  if not is_valid then
    error(string.format("Invalid configuration: %s", error_message))
  end

  Options = config
  return M.get_config()
end

return M
