local base = require("vimcino.display.base")
local deck_handler = require("vimcino.cards")
local hl = require("stack.win.hl")
local win = require("stack.win")
require("vimcino.meta.game_types")

local M = {}
M.buf = 0
M.win = 0

--- Create Blackjack game window
---@return number buf
---@return number win
function M.create_window()
  local opts = win.CenteredModal
  opts.w.width = 70
  opts.w.height = 18
  opts.w.title = "Blackjack"
  base.setup_highlights(hl.ns_id)
  return base.create_window(opts)
end

--- Creates highligts
---@param lines string[] data you want to highlight
---@param game_state Vimcino.Gamestate.Blackjack
---@return Stack.HighlightSpec
local function setupHighlights(lines, game_state)
  local highlights = {}

  vim.list_extend(highlights, hl.find_pattern(lines, "([%w%s]+):", "VimcinoLabel"))

  vim.list_extend(highlights, hl.find_pattern(lines, "Your Hand:", "VimcinoLabel"))

  vim.list_extend(highlights, hl.find_pattern(lines, "Hand Value:", "VimcinoLabel"))

  vim.list_extend(highlights, hl.find_pattern(lines, "Dealer Hand:", "VimcinoLabel"))
  if game_state.can_hit then
    vim.list_extend(highlights, hl.find_pattern(lines, "(%[HIDDEN%].+)$", "VimcinoHidden"))
  else
    vim.list_extend(highlights, hl.find_pattern(lines, "Dealer Hand:%s+(.+)$", "VimcinoCard"))
  end

  -- Highlight win/lose messages
  if game_state.winner then
    if game_state.winner == "You" then
      vim.list_extend(highlights, hl.find_pattern(lines, "(💰 YOU WON! 💰)", "VimcinoWin"))
    else
      vim.list_extend(highlights, hl.find_pattern(lines, "(Game Over! .+ wins!)", "VimcinoLose"))
    end
  end

  -- Highlight instructions
  vim.list_extend(highlights, hl.find_pattern(lines, "(Press .+)", "VimcinoInstruction"))
  return highlights
end

--- Generate the blackjack gameboard
---@param game_state Vimcino.Gamestate.Blackjack
---@return Stack.Win.Content
function M.generate_content(game_state)
  local content = {
    lines = {},
    highlights = {},
  }

  ---@type table<vimcino_stats>
  local game_info = { { name = "Decks", value = game_state.opts.number_of_decks } }
  local header = base.get_stats(game_info)
  table.insert(content.lines, header)
  table.insert(content.highlights, base.highlight_stats(header))

  -- Player Section
  table.insert(content.lines, "")

  local player_hand = "Your Hand: " .. deck_handler.display_cards_inline(game_state.player_cards)
  table.insert(content.lines, player_hand)
  local hand_value = "Hand Value: " .. game_state.player_value
  table.insert(content.lines, hand_value)

  -- Dealer Section
  local dealer_text, dealer_value_text
  if game_state.can_hit then
    dealer_text = "Dealer Hand: [HIDDEN], " .. deck_handler.display_cards_inline({ game_state.dealer_cards[2] })
    dealer_value_text = string.format("Hand Value: %d", game_state.dealer_cards[2].value)
  else
    dealer_text = "Dealer Hand: " .. deck_handler.display_cards_inline(game_state.dealer_cards)
    dealer_value_text = string.format("Hand Value: %d", game_state.dealer_value)
  end

  table.insert(content.lines, dealer_text)
  table.insert(content.lines, dealer_value_text)

  -- Results
  if game_state.winner then
    table.insert(content.lines, "")

    local result_text = game_state.winner == "You" and "💰 YOU WON! 💰"
      or string.format("Game Over! %s wins!", game_state.winner)
    table.insert(content.lines, result_text)
  end

  -- Instructions
  table.insert(content.lines, "")
  local instructions = "Press `h` to hit, `s` to stand, `=`/- to adjust bet"
  table.insert(content.lines, instructions)

  content.highlights = setupHighlights(content.lines, game_state)
  return content
end

function M.render(buf, content)
  base.render(buf, content)
end

return M
