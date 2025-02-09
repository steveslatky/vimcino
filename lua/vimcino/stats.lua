---@class vimcino.stats
local M = {
  name = "stats",
  opts = {},
  stats = {},
}

M.opts = require("vimcino.config").get_config(M.name)

---@class Stats
---@field currency number
---@field games_played number
---@field game_history table<string,number>
M.stats = {
  currency = 100,
  wins = 0,
  losses = 0,
  games_played = 0,
  game_history = {},
}

--- Gets folder vimcnio folder in vim data directory
---@return string folder path
local function get_default_data_dir()
  return vim.fn.stdpath("data") .. "/vimcino/"
end

--- Creates path for data if one does not exist
---@param dir_path string path to data
local function ensure_dir_exists(dir_path)
  if vim.fn.isdirectory(dir_path) == 0 then
    vim.fn.mkdir(dir_path, "p")
  end
end

--- Returns the most played game name
---@return string|nil The name of the game that was played the most
local function get_most_played()
  local max_key = nil
  local max_value = -math.huge -- Start with the smallest possible number

  for key, value in pairs(M.stats.game_history) do
    if value > max_value then
      max_value = value
      max_key = key
    end
  end
  return max_key
end

--- Gets the data path, default, or defended by user
---@return string path to data
local function get_data_dir()
  local stats_config = require("vimcino.config").get_config("stats")
  return stats_config.file_loc or get_default_data_dir()
end

--- Saves the data
---@param data Stats to be saved
local function save_data(data)
  local data_dir = get_data_dir()
  ensure_dir_exists(data_dir)
  local file_path = data_dir .. "stats.json"
  vim.fn.writefile({ vim.json.encode(data) }, file_path)
end

--- Loads stats from file
local function load_data()
  local data_dir = get_data_dir()
  local file_path = data_dir .. "stats.json"
  if vim.fn.filereadable(file_path) == 1 then
    local json_data = table.concat(vim.fn.readfile(file_path), "\n")
    return vim.json.decode(json_data)
  else
    return {}
  end
end

--- Setup stats
function M.setup()
  require("vimcino.config").get_config()

  ensure_dir_exists(get_data_dir())
  local data = load_data()
  if next(data) ~= nil then
    M.stats = data
  end
end

--- Updates stats with data provided
---@param new_data Stats
function M.update_stats(new_data)
  for k, v in pairs(new_data) do
    M.stats[k] = v
  end
  save_data(M.stats)
end

--- Update which games you have played
---@param game string name of the game
local function update_game_history(game)
  if not M.stats.game_history then
    M.stats.game_history = {}
  end

  if M.stats.game_history[game] == nil then
    M.stats.game_history[game] = 1
  else
    M.stats.game_history[game] = M.stats.game_history[game] + 1
  end
end

--- Updates stats for a win
---@param bet number Amount bet
---@param game string Game name
function M.game_won(bet, game)
  if bet > 0 then
    M.stats.wins = M.stats.wins + 1
  end
  update_game_history(game)
  M.stats.games_played = M.stats.games_played + 1
  M.stats.currency = M.stats.currency + bet
  save_data(M.stats)
end

--- Updates stats for a loss
---@param bet number Amount bet
---@param game string Game name
function M.game_lost(bet, game)
  M.stats.losses = M.stats.losses + 1
  M.game_won(-bet, game)
end

--- Opens a floating window to show stats
function M.show_stats()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = 50
  local height = 10

  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Add stats content to the buffer
  local stats = M.stats or {} -- Ensure stats is initialized
  local lines = {
    "=== Vimcino Stats ===",
    "",
    string.format("Currency: %d", stats.currency or 0),

    string.format("Wins: %d", stats.wins or 0),
    string.format("Losses: %d", stats.losses or 0),
    string.format("Games Played: %d", stats.games_played or 0),
    string.format("Most Played: %s", get_most_played() or "N/A"),
    "",
    "Press `q` to close",
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Highlight title
  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)

  -- Highlight each stat line
  for i, line in ipairs(lines) do
    local line_index = i - 1 -- Convert to 0-based index
    if line:find(": ") then
      local colon_pos = line:find(": ")
      local label_end_col = colon_pos + 1

      vim.api.nvim_buf_add_highlight(buf, -1, "Identifier", line_index, 0, label_end_col)

      if line:find("Most Played: ") then
        vim.api.nvim_buf_add_highlight(buf, -1, "String", line_index, label_end_col, -1)
      else
        vim.api.nvim_buf_add_highlight(buf, -1, "Number", line_index, label_end_col, -1)
      end
    end
  end

  -- Highlight keybindings
  vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 8, 0, -1)

  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })

  vim.api.nvim_set_option_value("filetype", "vimcino_stats", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
end

return M
