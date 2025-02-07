local M = {}

local games = require("vimcino.games")

function M.show()
	vim.ui.select(games.game_list, {
		prompt = "Select a game!:",
	}, function(choice)
		if not choice then
			return
		end

		local module_name = string.lower(choice):gsub("%s+", "")

		local status, game_module = pcall(require, string.format("vimcino.games.%s", module_name))
		if not status then
			vim.notify("Failed to load game: " .. module_name, vim.log.levels.ERROR)
			return
		end

		if type(game_module.start) == "function" then
			game_module.start()
		else
			vim.notify("Game module does not have a start function: " .. module_name, vim.log.levels.ERROR)
		end
	end)
end

return M
