local M = {}

-- Define your animation colors
vim.api.nvim_set_hl(0, "StackFlashColor", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "StackFlashColor2", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "StackGold", { fg = "#FFD700" })
vim.api.nvim_set_hl(0, "StackCherry", { fg = "#E32636" })
vim.api.nvim_set_hl(0, "StackOrange", { fg = "#FFA500" })
vim.api.nvim_set_hl(0, "StackCyan", { fg = "#00FFFF" })

local function decimal_to_hex(decimal)
  if not decimal then
    return "Normal"
  end
  return string.format("#%06x", decimal)
end

function M.flash_border(win_id, duration, interval)
  local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })

  local original_fg = decimal_to_hex(border_hl.fg)

  local timer = vim.uv.new_timer()
  local count = 0
  local max_flashes = duration / (interval * 2)

  timer:start(0, interval, function()
    vim.schedule(function()
      if count >= max_flashes then
        timer:stop()
        timer:close()
        -- Restore original border appearance
        vim.api.nvim_set_option_value("winhighlight", "FloatBorder:" .. original_fg, { win = win_id })
        return
      end

      -- Alternate between two colors
      local hl = count % 2 == 0 and "StackFlashColor" or "StackFlashColor2"
      vim.api.nvim_set_option_value("winhighlight", "FloatBorder:" .. hl, { win = win_id })
      count = count + 1
    end)
  end)
end

function M.flash_border_three_colors(win_id, duration, interval)
  local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })

  local original_fg = decimal_to_hex(border_hl.fg)
  Log.debug(original_fg)

  local timer = vim.uv.new_timer()
  local count = 0
  local max_flashes = duration / (interval * 2)

  timer:start(0, interval, function()
    vim.schedule(function()
      if count >= max_flashes then
        timer:stop()
        timer:close()
        -- Restore original border appearance
        vim.api.nvim_set_option_value("winhighlight", "FloatBorder:" .. original_fg, { win = win_id })
        return
      end

      -- Alternate between two colors
      local hl = count % 2 == 0 and "StackFlashColor" or "StackFlashColor2"
      vim.api.nvim_set_option_value("winhighlight", "FloatBorder:" .. hl, { win = win_id })
      count = count + 1
    end)
  end)
end

return M
