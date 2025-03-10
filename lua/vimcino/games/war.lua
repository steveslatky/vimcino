---@class vimcinco.games.war
---@field name string
---@field opts war.config
local M = {}

local bet_handler = require("vimcino.bet_handler")
local deck_handler = require("vimcino.cards")
local stats = require("vimcino.stats")

local game_state = {
  inital_deck = {},
  player_deck = {},
  player_discard = {},
  com_deck = {},
  com_discard = {},
  active_cards = {},
  buf = nil,
}

local function display_game_state(buf)
  local current_bet = bet_handler.get_bet(buf) or game_state.default_bet

  local instruction_lines = {}
  local result_line = nil

  local lines = {
    "=== WAR ===",
    string.format("Bet: %d", current_bet),
    string.format("Deck(s): %d", M.opts.number_of_decks),
    "",
    string.format("Player Card: %s", deck_handler.display_cards_inline(game_state.player_active)),
    "",
    string.format("Dealer Cards: %s", deck_handler.display_cards_inline(game_state.com_active)),
    "",
  }

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
    table.insert(lines, "Press `f` to fight, `q` to quit")
    instruction_lines = { #lines - 2, #lines - 1 }
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)

  for i, line in ipairs(lines) do
    local line_index = i - 1
    if line:find(": ") then
      local colon_pos = line:find(": ")
      local label_end_col = colon_pos + 1

      vim.api.nvim_buf_add_highlight(buf, -1, "Identifier", line_index, 0, label_end_col)
      vim.api.nvim_buf_add_highlight(buf, -1, "Number", line_index, label_end_col, -1)
    end
  end

  -- Highlight result line
  if result_line then
    local hl_group = game_state.winner == "You" and "VimcinoWin" or "VimcinoLose"
    vim.api.nvim_buf_add_highlight(buf, -1, hl_group, result_line, 0, -1)
  end

  -- Highlight instruction lines
  for _, line_index in ipairs(instruction_lines) do
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", line_index, 0, -1)
  end
end

local function draw_player()
  return table.remove(game_state.deck)
end

local function draw_com()
  return table.insert(game_state.com_active), table.remove(game_state.deck)
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
    buf = nil,
  }
  display_game_state(game_state.buf)
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
  reset_game_state()
  require("vimcino.games.init").setup_hl()

  local buf = vim.api.nvim_create_buf(false, true)
  game_state.buf = buf
  bet_handler.create(buf, 25, function(bufnr)
    display_game_state(bufnr)
  end)

  local width = 50
  local height = 15
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  local _ = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  display_game_state(buf)
  setup_keybindings()
end

-- Function to start the game
function M.start()
  M.setup()
end

return M
