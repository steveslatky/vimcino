local M = {}

---@class blackjack.config
---@field number_of_decks integer Number of decks to use in the game

---@class deathroll.config
---@field starting_number number Number you start the roll with
---@field computer_delay number The amount of milliseconds the computer will wait to roll

---@class stats.config
---@field file_loc? string Path to the statistics file

---@class rewards.config
---@field enable? boolean enable rewards
---@field goal number the number of key presses needed for a reward
---@field value number Value of fake currency to be rewarded with after goal is met
---@field notify boolean notify you received a reward

---@class vimcino.config
---@field stats stats.config Stats configuration
---@field blackjack blackjack.config Blackjack game configuration
---@field deathroll deathroll.config Deathroll game configuration
---@field rewards rewards.config Reward system

local Options = {}

-- Default configuration with documentation
---@type vimcino.config
M.default_config = {
  stats = {
    file_loc = nil,
  },
  blackjack = {
    number_of_decks = 1,
  },
  deathroll = {
    starting_number = 1000,
    computer_delay = 1000,
  },
  rewards = {
    enable = false,
    goal = 10000,
    value = 100,
    notify = false,
  },
}

-- Validate the configuration
---@param config vimcino.config
---@return boolean is_valid
---@return string? error_message
local function validate_config(config)
  -- Validate blackjack section
  if config.blackjack and type(config.blackjack.number_of_decks) ~= "number" then
    return false, "blackjack.number_of_decks must be a number"
  end

  -- Validate stats section
  if config.stats and config.stats.file_loc and type(config.stats.file_loc) ~= "string" then
    return false, "stats.file_loc must be a string"
  end

  -- Validate deathroll section
  if config.deathroll then
    if type(config.deathroll.starting_number) ~= "number" then
      return false, "deathroll.starting_number must be a number"
    end
    if type(config.deathroll.computer_delay) ~= "number" then
      return false, "deathroll.computer_delay must be a number"
    end
  end

  -- Validate rewards section
  if config.rewards then
    if type(config.rewards.enable) ~= "boolean" then
      return false, "rewards.enable must be a boolean"
    end
    if type(config.rewards.goal) ~= "number" then
      return false, "rewards.goal must be a number"
    end
    if type(config.rewards.value) ~= "number" then
      return false, "rewards.value must be a number"
    end
  end

  -- If all checks pass, return true
  return true, nil
end

-- Update the default config
---@param config? vimcino.config
---@return vimcino.config
local function extend(config)
  if not config then
    return vim.deepcopy(M.default_config)
  end
  return vim.tbl_deep_extend("force", vim.deepcopy(M.default_config), config)
end

-- Get the current configuration (full or specific module)
---@overload fun(): vimcino.config
---@overload fun(module: "blackjack"): blackjack.config
---@overload fun(module: "deathroll"): deathroll.config
---@overload fun(module: "stats"): stats.config
---@overload fun(module: "rewards") rewards.config
---@param module? string
---@return vimcino.config | blackjack.config | deathroll.config
function M.get_config(module)
  if module then
    return vim.deepcopy(Options[module] or {})
  end
  return vim.deepcopy(Options)
end

-- Setup options
---@param opts? vimcino.config User defined options
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
