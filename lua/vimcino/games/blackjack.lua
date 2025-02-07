local M = { name = "Blackjack" }

local bet_handler = require("vimcino.bet_handler")
local config = require("vimcino.config")
local deck_handler = require("vimcino.cards")
local stats = require("vimcino.stats")

---@class GameState.Blackjack
---@field deck table
---@field player_cards Deck
---@field dealer_cards Deck
---@field winner? string
---@field turn integer
---@field buf? integer
---@field default_bet integer

-- Private module state
---@type GameState.Blackjack
local game_state = {
  deck = {},
  player_cards = {},
  player_value = 0,
  dealer_cards = {},
  dealer_value = 0,
  winner = nil,
  turn = 1,
  buf = nil,
  default_bet = 25,
  can_hit = true,
}

-- Constants
local WINDOW_CONFIG = {
  width = 70,
  height = 15,
  style = "minimal",
  border = "rounded",
}

--- Updates value of all cards for each hand
local function update_values()
  local function calculate_hand_value(cards)
    local value = 0
    local aces = 0

    for _, card in ipairs(cards) do
      value = value + card.value
      if card.rank == "Ace" then
        aces = aces + 1
      end
    end

    -- Handle aces as 1 instead of 11 if over 21
    while value > 21 and aces > 0 do
      value = value - 10
      aces = aces - 1
    end

    return value
  end

  game_state.player_value = calculate_hand_value(game_state.player_cards)
  game_state.dealer_value = calculate_hand_value(game_state.dealer_cards)
end

--- Display the game state in the buffer
---@param buf integer Buffer index that will display the game
local function display_game_state(buf)
  local current_bet = bet_handler.get_bet(buf) or game_state.default_bet
  local dealer_display = ""
  local dealer_display_value = 0

  if game_state.can_hit then
    dealer_display = "[HIDDEN], " .. deck_handler.display_cards_inline({ game_state.dealer_cards[2] })
    dealer_display_value = game_state.dealer_cards[2].value
  else
    dealer_display = deck_handler.display_cards_inline(game_state.dealer_cards)
    dealer_display_value = game_state.dealer_value
  end

  local lines = {
    "=== Blackjack ===",
    string.format("Bet: %d", current_bet),
    string.format("Deck(s): %d", config.get_config().blackjack.number_of_decks),
    "",
    string.format("Player Cards: %s", deck_handler.display_cards_inline(game_state.player_cards)),
    string.format("Player Value: %d", game_state.player_value),
    "",
    string.format("Dealer Cards: %s", dealer_display),
    string.format("Dealer Value: %d", dealer_display_value),
    "",
  }

  if game_state.winner then
    table.insert(lines, string.format("Game Over! %s win(s)!", game_state.winner))
    table.insert(lines, "Press `p` to play again, `q` to quit")
  else
    table.insert(lines, "Press `=` to increase bet, '-' to decrease bet")
    table.insert(lines, "Press `h` to hit, `s` to stand, `q` to quit")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

--- Setting up controls for the game
---@param buf integer Buffer to display the game
local function setup_keybindings(buf)
  local keymap_opts = { noremap = true, silent = true }
  local keymaps = {
    { mode = "n", lhs = "h", rhs = ":lua require('vimcino.games.blackjack').hit()<CR>" },
    { mode = "n", lhs = "s", rhs = ":lua require('vimcino.games.blackjack').stand()<CR>" },
    { mode = "n", lhs = "p", rhs = ":lua require('vimcino.games.blackjack').restart()<CR>" },
    { mode = "n", lhs = "q", rhs = ":q<CR>" },
  }

  for _, keymap in ipairs(keymaps) do
    vim.api.nvim_buf_set_keymap(buf, keymap.mode, keymap.lhs, keymap.rhs, keymap_opts)
  end

  bet_handler.setup_keybindings(buf)
end

local function draw()
  return table.remove(game_state.deck)
end

--- Reset the game state with current configuration
local function reset_game_state()
  local conf = config.get_config()

  game_state = {
    deck = deck_handler.shuffle(deck_handler.gen_deck(conf.blackjack.number_of_decks)),
    player_cards = {},
    player_value = 0,
    dealer_cards = {},
    dealer_value = 0,
    winner = nil,
    turn = 1,
    buf = game_state.buf,
    default_bet = 25,
    can_hit = true,
  }
  table.insert(game_state.dealer_cards, draw())
  table.insert(game_state.dealer_cards, draw())
  table.insert(game_state.player_cards, draw())
  table.insert(game_state.player_cards, draw())
  update_values()
end

--- Create centered window
---@param buf integer Buffer to display
---@return integer win Window handle
local function create_centered_window(buf)
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - WINDOW_CONFIG.height) / 2)
  local col = math.floor((ui.width - WINDOW_CONFIG.width) / 2)

  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = WINDOW_CONFIG.width,
    height = WINDOW_CONFIG.height,
    row = row,
    col = col,
    style = WINDOW_CONFIG.style,
    border = WINDOW_CONFIG.border,
  })
end

--- Find the winder of the game
local function choose_winner()
  local current_bet = bet_handler.get_bet(game_state.buf)
  local player_bust = game_state.player_value > 21
  local dealer_bust = game_state.dealer_value > 21

  -- Player busts immediately lose
  if player_bust then
    game_state.winner = "Dealer"
    stats.game_lost(current_bet, M.name)
  -- Dealer busts and player didn't
  elseif dealer_bust then
    game_state.winner = "You"
    stats.game_won(current_bet, M.name)
  -- Compare values when both hands are valid
  else
    if game_state.player_value > game_state.dealer_value then
      game_state.winner = "You"
      stats.game_won(current_bet, M.name)
    elseif game_state.dealer_value > game_state.player_value then
      game_state.winner = "Dealer"
      stats.game_lost(current_bet, M.name)
    else
      game_state.winner = "Push" -- Tie
    end
  end

  display_game_state(game_state.buf)
end

local function dealers_turn()
  local function draw_step()
    display_game_state(game_state.buf)

    if game_state.dealer_value < 17 then
      vim.defer_fn(function()
        table.insert(game_state.dealer_cards, draw())
        update_values()
        draw_step()
      end, 2000)
    else
      vim.defer_fn(function()
        choose_winner()
      end, 1000)
    end
  end

  -- Initial dealer card reveal
  game_state.can_hit = false
  draw_step()
end

--- Player is done taking cards, dealers turn
function M.stand()
  game_state.can_hit = false
  display_game_state(game_state.buf)
  dealers_turn()
end

--- Player takes another card
function M.hit()
  if not game_state.can_hit or game_state.player_value > 21 then
    return
  end
  table.insert(game_state.player_cards, draw())
  update_values()

  if game_state.buf then
    display_game_state(game_state.buf)
  end

  if game_state.player_value > 21 then
    game_state.can_hit = false
    dealers_turn()
  end
end

--- Restart the game to play again
function M.restart()
  reset_game_state()
  if game_state.buf then
    display_game_state(game_state.buf)
  end
end

--- Setup game window
function M.setup()
  if not config.get_config().blackjack then
    error("Blackjack configuration not found. Please run setup() first.")
  end

  reset_game_state()

  local buf = vim.api.nvim_create_buf(false, true)
  game_state.buf = buf

  bet_handler.create(buf, game_state.default_bet, function(bufnr)
    display_game_state(bufnr)
  end)

  create_centered_window(buf)
  display_game_state(buf)
  setup_keybindings(buf)
end

-- Alias for setup for easier startup
function M.start()
  M.setup()
end

return M
