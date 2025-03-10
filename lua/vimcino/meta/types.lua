---@class games.deathroll.config
---@field starting_number number Number you start the roll with
---@field computer_delay number The amount of milliseconds the computer will wait to roll
---
---@class games.war.config
---@field number_of_decks integer Number of decks to use in the game

---@class stats.config
---@field file_loc? string Path to the statistics file

---@class rewards.config
---@field enable? boolean Enable rewards
---@field goal number The number of key presses needed for a reward
---@field value number Value of fake currency to be rewarded with after goal is met
---@field notify boolean Notify you received a reward
---
---@class games.blackjack.config @field number_of_decks integer Number of decks to use in the game
---@field number_of_decks number amount of decks in the game
---@field hit_delay number milliseconds between computer hits
