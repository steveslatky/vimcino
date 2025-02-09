local M = {}

M.game_list = { "Deathroll", "Blackjack" }

function M.setup_hl()
  vim.api.nvim_set_hl(0, "VimcinoWin", { fg = "#98c379", bg = "#1e1e1e" })
  vim.api.nvim_set_hl(0, "VimcinoLose", { fg = "#e06c75", bg = "#1e1e1e" })
end

return M
