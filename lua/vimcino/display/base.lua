local bet_handler = require("vimcino.bet_handler")
local M = {}

M.winId = 0
M.bufId = 0

local hl = require("stack.win.hl")
local win = require("stack.win")

---@class HlGroups
---@field header string
---@field label string
---@field value string
---@field card string
---@field win string
---@field lose string
---@field instruction string
---@field hidden string

---@class WindowConfig
---@field width integer
---@field height integer
---@field border string
---@field hl_groups HlGroups

M.default_config = {
  hl_groups = {
    header = "VimcinoHeader",
    label = "VimcinoLabel",
    value = "VimcinoValue",
    card = "VimcinoCard",
    win = "VimcinoWin",
    lose = "VimcinoLose",
    instruction = "VimcinoInstruction",
    hidden = "VimcinoHidden",
  },
}

---@class vimcino_stats
---@field name string
---@field value function|string|number

---@class vimcino.GameContent
---@field name string
---@field game_state table
---@field vimcino_stats table<vimcino_stats>
---@field instructions table<string>
local default_game_content = {
  name = "",
  game_state = {},
  vimcino_stats = {
    { name = "Bet", value = require("vimcino.bet_handler").get_current_bet },
    { name = "Bank Value", value = require("vimcino.stats").get_bank_value },
  },
  instructions = {},
}

--- Gen highlights for stats
---@param text string[]|string
---@return Stack.HighlightSpec[]
function M.highlight_stats(text)
  -- Split into lines if needed
  local lines = type(text) == "string" and { text } or text

  ---@type Stack.HighlightSpec
  local highlights = {}

  -- Pattern for names (words before colon)
  local name_pattern = "([%w%s]+):"
  local name_highlights = hl.find_pattern(lines, name_pattern, "Title")

  -- Pattern for values (numbers after colon)
  local value_pattern = ": (%d+)"
  local value_highlights = hl.find_pattern(lines, value_pattern, "Question")

  vim.list_extend(highlights, name_highlights)
  vim.list_extend(highlights, value_highlights)

  return highlights
end

--- Generate game header
---@param game_stats table<vimcino_stats>|nil
---@return string
function M.get_stats(game_stats)
  local stat_line = ""
  local default_stats = default_game_content.vimcino_stats
  local additional_stats = game_stats or {}

  -- process default stats
  for i, line in ipairs(default_stats) do
    local v = -1
    if type(line.value) == "function" then
      v = line.value()
    else
      v = line.value
    end
    stat_line = stat_line .. string.format("%s : %s", line.name, v)
    if i < #default_stats or #additional_stats > 0 then
      stat_line = stat_line .. " | "
    end
  end

  -- Process additional stats
  for i, line in ipairs(additional_stats) do
    local v = -1
    if type(line.value) == "function" then
      v = line.value()
    else
      v = line.value
    end
    stat_line = stat_line .. string.format("%s : %s", line.name, v)
    if i < #additional_stats then
      stat_line = stat_line .. " | "
    end
  end

  return stat_line
end

---@class HighlightRange
---@field start integer
---@field finish integer
---@field group string

---@class LineSpec
---@field text string
---@field hl? HighlightRange[]

---@param game vimcino.GameContent
---@param hl_groups HlGroups
---@return LineSpec[]
local function render_board(game, hl_groups)
  ---@type LineSpec[]
  local lines = {}

  local stats_line = get_stats()
  ---@type HighlightRange[]
  local stats_hl = {}
  for label, value in pairs(game.vimcino_stats) do
    local full_text = label .. ": " .. value .. "  "
    local label_length = #label + 1 -- Include colon
    local value_start = label_length + 1
    local value_length = #value

    table.insert(stats_hl, {
      start = #stats_line,
      finish = #stats_line + label_length,
      group = hl_groups.label,
    })

    table.insert(stats_hl, {
      start = #stats_line + label_length,
      finish = #stats_line + label_length + value_length,
      group = hl_groups.value,
    })

    stats_line = stats_line .. full_text
  end

  table.insert(lines, {
    text = stats_line:sub(1, -3),
    hl = stats_hl,
  })
  table.insert(lines, { text = "" })

  -- Render game state
  for _, line in ipairs(game.game_state) do
    table.insert(lines, {
      text = line.text,
      hl = line.hl and vim.tbl_map(function(h)
        return {
          start = h.start,
          finish = h.finish,
          group = h.group and hl_groups[h.group] or hl_groups.card,
        }
      end, line.hl) or nil,
    })
  end

  table.insert(lines, { text = "" })

  -- Render instructions
  for _, instruction in ipairs(game.instructions) do
    table.insert(lines, {
      text = instruction,
      hl = { { start = 0, finish = #instruction, group = hl_groups.instruction } },
    })
  end

  return lines
end

---@param game vimcino.GameContent
---@param config? Stack.Win.Config
function M.new_game(game, config)
  config = config or M.default_config
  config.w = config.w or {}
  config.w.title = game.name
  config.w.footer = " 'q' to Quit, 'p' to Play again "

  -- Create window and buffer
  local buf, win_handle = win.create_window(config)

  -- Render game content
  local content = render_board(game, config.hl_groups)
  win.render(buf, content)

  return buf, win_handle
end

---Create a centered window with configuration
---@param config? Stack.Win.Config Configuration overrides
---@return number buf Buffer handle
---@return number win Window handle
function M.create_window(config)
  if config ~= nil then
    config.w.footer = " 'q' to Quit, 'p' to Play again "
    M.bufId, M.winId = win.create_window(config)
    return M.bufId, M.winId
  end
  M.bufId, M.winId = win.create_window(config)
  return M.bufId, M.winId
end

---Set up default highlight groups
function M.setup_highlights(ns_id)
  local hg = {
    VimcinoHeader = { fg = "#FFD700", bold = true },
    VimcinoLabel = { fg = "#569CD6" },
    VimcinoHidden = { fg = "#CE9178" },
    VimcinoCard = { fg = "#FFFFFF" },
    VimcinoInstruction = { fg = "#808080" },
    VimcinoHidden = { fg = "#696969" },
    VimcinoWin = { fg = "#98C379", bold = true },
    VimcinoLose = { fg = "#E06C75", bold = true },
  }
  hl.setup_highlight_groups(hg)
end

---Render content to buffer with highlighting
---@param buf number Buffer handle to render to
---@param content Stack.Win.Content Table of lines with optional highlight specs
function M.render(buf, content)
  hl.render(buf, content)
end

return M
