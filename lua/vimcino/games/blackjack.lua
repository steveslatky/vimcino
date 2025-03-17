---@class vimcino.games.blackjack
---@field name string
---@field opts games.blackjack.config
local M = { name = "Blackjack" }

local animate = require("stack.animation.win")
local bet_handler = require("vimcino.bet_handler")
local config = require("vimcino.config")
local deck_handler = require("vimcino.cards")
local display_blackjack = require("vimcino.display.blackjack")
local sparkle = require("stack.animation.sparkles")
local stats = require("vimcino.stats")

local default_opts = {
  number_of_decks = 1,
  hit_delay = 1000,
}
---@diagnostic disable-next-line: assign-type-mismatch
M.opts = config.get_config(M.name) or default_opts

-- Private module state
---@type Vimcino.Gamestate.Blackjack
local game_state = {
  deck = {},
  ---@diagnostic disable-next-line: missing-fields
  player_cards = {},
  player_value = 0,
  ---@diagnostic disable-next-line: missing-fields
  dealer_cards = {},
  dealer_value = 0,
  winner = nil,
  turn = 1,
  buf = nil,
  default_bet = 25,
  can_hit = true,
  opts = M.opts,
}

local function display_game_state(state, buf)
  assert(vim.api.nvim_buf_is_valid(buf), "Invalid buffer handle")
  local content = display_blackjack.generate_content(state)
  display_blackjack.render(buf, content)
  if game_state.winner == "You" then
    animate.flash_border(M.win, {
      duration = 1500,
      interval = 150,
      highlights = { "StackPurple", "StackGreen" },
    })
  elseif game_state.winner == "Dealer" then
    animate.flash_border(M.win, "error")
  end
end

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

function M.flash()
  animate.flash_border(M.win, "vapor_wave")
  sparkle.add_sparkles()
end

--- Setting up controls for the game
---@param buf integer Buffer to display the game
local function setup_keybindings(buf)
  local keymap_opts = { noremap = true, silent = true }
  local keymaps = {
    { mode = "n", lhs = "h", rhs = ":lua require('vimcino.games.blackjack').hit()<CR>" },
    { mode = "n", lhs = "s", rhs = ":lua require('vimcino.games.blackjack').stand()<CR>" },
    { mode = "n", lhs = "p", rhs = ":lua require('vimcino.games.blackjack').restart()<CR>" },
    { mode = "n", lhs = "t", rhs = ":lua require('vimcino.games.blackjack').flash()<CR>" },
    { mode = "n", lhs = "q", rhs = ":q<CR>" },
  }

  for _, keymap in ipairs(keymaps) do
    vim.api.nvim_buf_set_keymap(buf, keymap.mode, keymap.lhs, keymap.rhs, keymap_opts)
  end

  bet_handler.setup_keybindings(buf)
end

--- Draw from the deck
---@return Card
local function draw()
  return table.remove(game_state.deck)
end

--- Reset the game state with current configuration
local function reset_game_state()
  local conf = config.get_config()

  game_state = {
    deck = deck_handler.shuffle(deck_handler.gen_deck(conf.blackjack.number_of_decks)),
    ---@diagnostic disable-next-line: missing-fields
    player_cards = {},
    player_value = 0,
    ---@diagnostic disable-next-line: missing-fields
    dealer_cards = {},
    dealer_value = 0,
    winner = nil,
    turn = 1,
    buf = game_state.buf,
    default_bet = 25,
    can_hit = true,
    opts = M.opts,
  }
  table.insert(game_state.dealer_cards, draw())
  table.insert(game_state.dealer_cards, draw())
  table.insert(game_state.player_cards, draw())
  table.insert(game_state.player_cards, draw())
  update_values()
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

  display_game_state(game_state, game_state.buf)
end

local function dealers_turn()
  local function draw_step()
    display_game_state(game_state, game_state.buf)

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
  display_game_state(game_state, game_state.buf)
  dealers_turn()
end

--- Player takes another card
function M.hit()
  if not game_state.can_hit or game_state.player_value > 21 then
    return
  end

  -- Ensure we have a valid buffer reference
  if not game_state.buf or not vim.api.nvim_buf_is_valid(game_state.buf) then
    vim.notify("No valid game window found!", vim.log.levels.ERROR)
    return
  end

  local drawn = draw()
  table.insert(game_state.player_cards, drawn)
  update_values()

  -- Add visual feedback for the new card
  -- display_blackjack.animate_card_reveal(game_state.buf, #game_state.player_cards)
  display_game_state(game_state, game_state.buf)

  if game_state.player_value > 21 then
    game_state.can_hit = false
    dealers_turn()
  end
end

--- Restart the game to play again
function M.restart()
  reset_game_state()
  if game_state.buf and vim.api.nvim_buf_is_valid(game_state.buf) then
    display_game_state(game_state, game_state.buf)
  end
end

--- Setup the game
function M.setup()
  if game_state.buf and vim.api.nvim_buf_is_valid(game_state.buf) then
    vim.api.nvim_buf_delete(game_state.buf, { force = true })
  end

  local buf, win = display_blackjack.create_window()
  game_state.buf = buf
  M.win = win

  require("vimcino.bet_handler").create(buf, game_state.default_bet, function(bufid)
    display_game_state(game_state, bufid)
  end)

  setup_keybindings(buf)

  reset_game_state()
  display_game_state(game_state, buf)
end

-- Alias for setup for easier startup
function M.start()
  M.setup()
end

return M
