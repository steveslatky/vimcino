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
  opts.w.width = 60
  opts.w.height = 14
  opts.w.title = "Deathroll"
  base.setup_highlights()
  return base.create_window(opts)
end

--- Creates highligts
---@param lines string[] data you want to highlight
---@param game_state Vimcinco.Gamestate.Deathroll
---@return Stack.HighlightSpec
local function setupHighlights(lines, game_state)
  local highlights = {}

  vim.list_extend(highlights, hl.find_pattern(lines, "([%w%s]+):", "VimcinoLabel"))

  vim.list_extend(highlights, hl.find_pattern(lines, "Current Number:", "VimcinoLabel"))

  vim.list_extend(highlights, hl.find_pattern(lines, "Current Player:", "VimcinoLabel"))

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

--- Helper to show the roll history
---@param game_state Vimcinco.Gamestate.Deathroll
---@return string
local function display_roll_log(game_state)
  local log = ""
  for i = #game_state.roll_log, math.max(1, #game_state.roll_log - 5), -1 do
    log = log .. string.format("  %d", game_state.roll_log[i])
  end
  return log
end

--- Generate the blackjack gameboard
---@param game_state Vimcinco.Gamestate.Deathroll
---@return Stack.Win.Content
function M.generate_content(game_state)
  local content = {
    lines = {},
    highlights = {},
  }

  ---@type table<vimcino_stats>
  local game_info = { { name = "Starting number", value = game_state.starting_number } }
  local header = base.get_stats(game_info)
  table.insert(content.lines, header)
  table.insert(content.highlights, base.highlight_stats(header))
  table.insert(content.lines, "")

  table.insert(content.lines, string.format("Current Number: %d", game_state.current_number))
  table.insert(content.lines, string.format("Current Player: %s", game_state.current_player))
  table.insert(content.lines, "")

  if #game_state.roll_log > 0 then
    table.insert(content.lines, "Roll History:")
    table.insert(content.lines, display_roll_log(game_state))
    table.insert(content.lines, "")
  else
    table.insert(content.lines, "")
    table.insert(content.lines, "")
    table.insert(content.lines, "")
  end
  -- Results
  if game_state.winner then
    table.insert(content.lines, "")

    local result_text = game_state.winner == "You" and "💰 YOU WON! 💰"
      or string.format("Game Over! %s wins!", game_state.winner)
    table.insert(content.lines, result_text)
  end

  -- Instructions
  table.insert(content.lines, "")
  table.insert(content.lines, "Press `=` to increase bet, '-' to decrease bet")
  table.insert(content.lines, "Press `r` to roll, `q` to quit")

  content.highlights = setupHighlights(content.lines, game_state)
  return content
end

function M.render(buf, content)
  base.render(buf, content)
end

return M
