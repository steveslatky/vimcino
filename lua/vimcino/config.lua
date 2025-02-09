local M = {}

---@class blackjack.Config
---@field number_of_decks integer Number of decks to use in the game

---@class deathroll.Config
---@field starting_number number Number you start the roll with
---@field computer_start boolean If true computer will start the game

---@class stats.Config
---@field file_loc? string Path to the statistics file

---@class vimcino.Config
---@field stats stats.Config Stats configuration
---@field blackjack blackjack.Config Blackjack game configuration
---@field deathroll deathroll.Config Deathroll game configuration

local Options = {}

-- Default configuration with documentation
---@type vimcino.Config
M.default_config = {
  stats = {
    file_loc = nil,
  },
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

  if config.stats.file_loc and type(config.stats.file_loc) ~= "string" then
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

-- Get the current configuration (full or specific module)
---@overload fun(): vimcino.Config
---@overload fun(module: "blackjack"): blackjack.Config
---@overload fun(module: "deathroll"): deathroll.Config
---@overload fun(module: "stats"): stats.Config
---@param module? string
---@return vimcino.Config | blackjack.Config | deathroll.Config
function M.get_config(module)
  if module then
    return vim.deepcopy(Options[module] or {})
  end
  return vim.deepcopy(Options)
end

-- Setup options
---@param opts? vimcino.Config User defined options
---@error "Invalid configuration" when the configuration is invalid
function M.setup(opts)
  local config = extend(opts)

  -- Validate configuration
  local is_valid, error_message = validate_config(config)
  if not is_valid then
    error(string.format("Invalid configuration: %s", error_message))
  end

  Options = config
end

return M
