---@class vimcinco.games.deathroll
local M = { name = "Deathroll" }

local bet_handler = require("vimcino.bet_handler")
local stats = require("vimcino.stats")

---@class GameState
---@field starting_number integer  # The default starting number for the game (e.g., 1000).
---@field current_number integer   # The current roll limit or target number.
---@field current_player "You" | "Computer"  # The current player ("You" or "Computer").
---@field last_roll integer | nil  # The result of the last dice roll (nil if no roll has been made yet).
---@field winner "You" | "Computer" | nil  # The winner of the game (nil if the game is ongoing).
---@field roll_log integer[]       # A log of all dice rolls made during the game.
---@field buf number|nil  -- Added buffer reference

---@type GameState
local game_state = {
  starting_number = 1000,
  current_number = 1000,
  current_player = "You",
  last_roll = nil,
  winner = nil,
  roll_log = {},
  buf = nil,
}

--- Gets a random number from 1 to N
---@param n number Top range of roll
---@return number
local function roll_number(n)
  return math.random(1, n)
end

--- Updates the game state and check for a winner
local function update_game_state()
  if game_state.current_number == 1 then
    game_state.winner = game_state.current_player == "You" and "Computer" or "You"
    local current_bet = bet_handler.get_bet(game_state.buf)

    if game_state.winner == "You" then
      stats.game_won(current_bet, M.name)
    else
      stats.game_lost(current_bet, M.name)
    end
  else
    game_state.current_player = game_state.current_player == "You" and "Computer" or "You"
  end
end

--- Display the game state in the buffer
---@param buf number buffer index that will display the game
local function display_game_state(buf)
  local lines = {
    "=== Deathroll Game ===",
    bet_handler.get_bet(buf) and string.format("Bet: %d", bet_handler.get_bet(buf)) or "Bet: 25",
    string.format("Money Held: %d", stats.get_bank_value()),
    "",
    string.format("Starting Number: %d", game_state.starting_number),
    string.format("Current Number: %d", game_state.current_number),
    string.format("Current Player: %s", game_state.current_player),
    "",
  }

  -- Store highlight positions
  local instruction_lines = {}
  local result_line = nil

  if game_state.winner then
    if game_state.winner == "You" then
      table.insert(lines, "💰 YOU WON! 💰")
      result_line = #lines - 1
    else
      table.insert(lines, string.format("Game Over! %s wins!", game_state.winner))
      result_line = #lines - 1
    end
    table.insert(lines, "Press `p` to play again, `q` to quit")
    instruction_lines = { #lines - 1 }
  else
    table.insert(lines, "Press `=` to increase bet, '-' to decrease bet")
    table.insert(lines, "Press `r` to roll, `q` to quit")
    instruction_lines = { #lines - 2, #lines - 1 }
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Highlight title
  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)

  -- Highlight game state lines
  for i, line in ipairs(lines) do
    local line_index = i - 1 -- Convert to 0-based index
    if line:find(": ") then
      local colon_pos = line:find(": ")
      local label_end_col = colon_pos + 1

      vim.api.nvim_buf_add_highlight(buf, -1, "Identifier", line_index, 0, label_end_col)
      vim.api.nvim_buf_add_highlight(buf, -1, "Number", line_index, label_end_col, -1)
    end
  end

  if result_line then
    local hl_group = game_state.winner == "You" and "VimcinoWin" or "VimcinoLose"
    vim.api.nvim_buf_add_highlight(buf, -1, hl_group, result_line, 0, -1)
  end

  -- Highlight instruction lines
  for _, line_index in ipairs(instruction_lines) do
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", line_index, 0, -1)
  end
end

--- Function to handle the player's roll
function M.roll()
  if game_state.winner then
    vim.notify("The game is already over. Restart with p to play again.", vim.log.levels.WARN)
    return
  end

  -- Player rolls
  game_state.last_roll = roll_number(game_state.current_number)
  game_state.current_number = game_state.last_roll

  update_game_state()
  display_game_state(vim.api.nvim_win_get_buf(0))

  if not game_state.winner then
    vim.defer_fn(function()
      game_state.last_roll = roll_number(game_state.current_number)
      game_state.current_number = game_state.last_roll

      update_game_state()

      display_game_state(vim.api.nvim_win_get_buf(0))
    end, 1000)
  end
end

--- Reset the game state
local function reset_game_state()
  game_state = {
    starting_number = 1000,
    current_number = 1000,
    current_player = "You",
    last_roll = nil,
    winner = nil,
    roll_log = {},
    bet = 25,
  }
end

--- Restarts the game to the initial state
function M.restart()
  reset_game_state()
  -- bet_handler.create(game_state.buf, 25)
  display_game_state(vim.api.nvim_win_get_buf(0))
end

--- Setup controls for the game
---@param buf number buffer index
local function setup_keybindings(buf)
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "r",
    ":lua require('vimcino.games.deathroll').roll()<CR>",
    { noremap = true, silent = true }
  )

  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "p",
    ":lua require('vimcino.games.deathroll').restart()<CR>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(game_state.buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

  bet_handler.setup_keybindings(game_state.buf)
end

--- Setup the game
function M.setup()
  reset_game_state()
  require("vimcino.games.init").setup_hl()

  local buf = vim.api.nvim_create_buf(false, true)
  game_state.buf = buf
  bet_handler.create(buf, 25, function(bufnr)
    display_game_state(bufnr)
  end)

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

  display_game_state(buf)
  setup_keybindings(buf)
end

-- Function to start the game
function M.start()
  M.setup()
end

return M
