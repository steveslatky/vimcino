---@class vimcinco.games.war
---@field name string
---@field opts games.war.config
local M = { name = "War" }

M.opts = require("vimcino.config").get_config(string.lower(M.name))

local animate = require("stack.animation.win")
local bet_handler = require("vimcino.bet_handler")
local deck_handler = require("vimcino.cards")
local display_war = require("vimcino.display.war")
local hl = require("stack.win.hl")

local game_state = {
  inital_deck = {},
  player_deck = {},
  player_discard = {},
  com_deck = {},
  com_discard = {},
  active_cards = {},
  buf = nil,
}

local function display_game_state(state)
  Log.debug(state)
  assert(vim.api.nvim_buf_is_valid(state.buf), "Invalid buffer handle")

  local content = display_war.generate_content(state)
  hl.render(game_state.buf, content)
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

local function draw_player()
  return table.remove(game_state.deck)
end

local function draw_com()
  local card = table.remove(game_state.deck)
  table.insert(game_state.com_active, card)
  return card
end

function M.fight()
  table.insert(game_state.player_active, draw_player())
  table.insert(game_state.com_active, draw_com())
end

local function reset_game_state()
  game_state = {
    inital_deck = deck_handler.gen_deck(M.opts.number_of_decks),
    player_deck = {},
    player_discard = {},
    player_active = {},
    com_deck = {},
    com_discard = {},
    com_active = {},
  }
  display_game_state(game_state)
end

function M.restart()
  reset_game_state()
end

local function setup_keybindings()
  local keymap_opts = { noremap = true, silent = true }
  local keymaps = {
    { mode = "n", lhs = "h", rhs = ":lua require('vimcino.games.war').fight()<CR>" },
    { mode = "n", lhs = "p", rhs = ":lua require('vimcino.games.war').restart()<CR>" },
    { mode = "n", lhs = "q", rhs = ":q<CR>" },
  }

  for _, keymap in ipairs(keymaps) do
    vim.api.nvim_buf_set_keymap(game_state.buf, keymap.mode, keymap.lhs, keymap.rhs, keymap_opts)
  end

  bet_handler.setup_keybindings(game_state.buf)
end

--- Setup the game
function M.setup()
  local buf, win = display_war.create_window()
  Log.debug({ buf, win })
  game_state.buf = buf
  M.win = win

  bet_handler.create(buf, 25, function()
    display_game_state(game_state)
  end)

  reset_game_state()
  display_game_state(game_state)
  setup_keybindings()
end

-- Function to start the game
function M.start()
  M.setup()
end

return M
