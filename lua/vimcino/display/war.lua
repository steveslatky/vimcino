local M = {}

local base = require("vimcino.display.base")
local deck_handler = require("vimcino.cards")
local hl = require("stack.win.hl")
local win = require("stack.win")
require("vimcino.meta.game_types")

---@return number buf
---@return number win
function M.create_window()
  local opts = win.CenteredModal
  opts.w.width = 70
  opts.w.height = 18
  opts.w.title = "War"
  base.setup_highlights()
  return base.create_window(opts)
end

--- Creates highligts
---@param lines string[] data you want to highlight
---@param game_state Vimcino.Gamestate.Blackjack
---@return Stack.HighlightSpec
local function setupHighlights(lines, game_state)
  local highlights = {}

  vim.list_extend(highlights, hl.find_pattern(lines, "([%w%s]+):", "VimcinoLabel"))

  -- Highlight win/lose messages
  if game_state.winner then
    if game_state.winner == "You" then
      vim.list_extend(highlights, hl.find_pattern(lines, "(💰 YOU WON! 💰)", "VimcinoWin"))
    else
      vim.list_extend(highlights, hl.find_pattern(lines, "(Game Over! .+ wins!)", "VimcinoLose"))
    end
  end

  vim.list_extend(highlights, hl.find_pattern(lines, "(Press .+)", "VimcinoInstruction"))
  return highlights
end

function M.generate_content(game_state)
  local content = {
    highlights = {},
  }
  content.lines = {
    "",
    string.format("Player Card: %s", deck_handler.display_cards_inline(game_state.player_active)),
    string.format("Deck size: %s", #game_state.player_deck),
    string.format("Dealer Cards: %s", deck_handler.display_cards_inline(game_state.com_active)),
    string.format("Deck size: %s", #game_state.com_deck),
    "",
  }

  if game_state.winner then
    if game_state.winner == "You" then
      table.insert(content.lines, "💰 YOU WON! 💰")
    else
      table.insert(content.lines, string.format("Game Over! %s wins!", game_state.winner))
    end
  else
    table.insert(content.lines, "Press `=` to increase bet, '-' to decrease bet")
    table.insert(content.lines, "Press `f` to fight, `q` to quit")
  end

  setupHighlights(content.lines, game_state)
  return content
end

return M
