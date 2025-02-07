-- vimcino/bet_handler.lua
local M = {}

local bets = {}

-- Cleanup bets when buffers are closed
vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(args)
		local buf = tonumber(args.buf)
		bets[buf] = nil
	end,
})

--- Creates or resets the bet for a buffer
---@param buf number
---@param initial_bet number|nil
function M.create(buf, initial_bet, on_change)
	bets[buf] = {
		current_bet = initial_bet or 25,
		on_change = on_change,
	}
end

--- Adjusts the bet for the current buffer
---@param amount number
function M.change_bet(amount)
	local buf = vim.api.nvim_get_current_buf()
	local bet = bets[buf]
	if not bet then
		return
	end

	if amount < 0 and bet.current_bet <= math.abs(amount) then
		return
	end
	bet.current_bet = bet.current_bet + amount
	if bet.on_change then
		bet.on_change(buf)
	end
end

--- Gets the current bet for a buffer
---@param buf number
---@return number
function M.get_bet(buf)
	return bets[buf] and bets[buf].current_bet or 0
end

--- Sets up bet adjustment keybindings
---@param buf number
function M.setup_keybindings(buf)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"=",
		":lua require('vimcino.bet_handler').change_bet(5)<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"-",
		":lua require('vimcino.bet_handler').change_bet(-5)<CR>",
		{ noremap = true, silent = true }
	)
end

return M
