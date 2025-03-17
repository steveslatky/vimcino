---@class vimcinco.games.deathroll
---@field name string
---@field opts games.deathroll.config
local M = { name = "Deathroll" }

local animate = require("stack.animation.win")
local bet_handler = require("vimcino.bet_handler")
local display_deathroll = require("vimcino.display.deathroll")
local stats = require("vimcino.stats")

---@diagnostic disable-next-line: assign-type-mismatch
M.opts = require("vimcino.config").get_config(string.lower(M.name))

---@type Vimcinco.Gamestate.Deathroll
local game_state = {
  starting_number = M.opts.starting_number or 1000,
  current_number = M.opts.starting_number or 1000,
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
---@param state Vimcinco.Gamestate.Deathroll
---@param buf number buffer index that will display the game
local function display_game_state(state, buf)
  assert(vim.api.nvim_buf_is_valid(buf), "Invalid buffer handle")
  local content = display_deathroll.generate_content(state)
  display_deathroll.render(buf, content)
  if game_state.winner == "You" then
    animate.flash_border(M.win, {
      duration = 1500,
      interval = 150,
      highlights = { "StackPurple", "StackGreen" },
    })
  elseif game_state.winner == "Computer" then
    animate.flash_border(M.win, "error")
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
  table.insert(game_state.roll_log, game_state.last_roll)

  update_game_state()
  display_game_state(game_state, vim.api.nvim_win_get_buf(0))

  if not game_state.winner then
    vim.defer_fn(function()
      game_state.last_roll = roll_number(game_state.current_number)
      game_state.current_number = game_state.last_roll
      table.insert(game_state.roll_log, game_state.last_roll)

      update_game_state()

      display_game_state(game_state, vim.api.nvim_win_get_buf(0))
    end, 1000)
  end
end

--- Reset the game state
local function reset_game_state()
  game_state = {
    starting_number = M.opts.starting_number,
    current_number = M.opts.starting_number,
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
  display_game_state(game_state, vim.api.nvim_win_get_buf(0))
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

  local buf, win = display_deathroll.create_window()
  game_state.buf = buf
  M.win = win
  bet_handler.create(buf, 25, function(bufnr)
    display_game_state(game_state, bufnr)
  end)

  display_game_state(game_state, buf)
  setup_keybindings(buf)
end

-- Function to start the game
function M.start()
  M.setup()
end

return M
