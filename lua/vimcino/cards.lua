local M = {}

---@class Card a normal card
---@field suit string
---@field rank string
---@field value number

---@class Deck a deck of cards
---@field cards Card[] @ Array of cards

M.deck = {
  -- Hearts
  { suit = "hearts", rank = "2", value = 2 },
  { suit = "hearts", rank = "3", value = 3 },
  { suit = "hearts", rank = "4", value = 4 },
  { suit = "hearts", rank = "5", value = 5 },
  { suit = "hearts", rank = "6", value = 6 },
  { suit = "hearts", rank = "7", value = 7 },
  { suit = "hearts", rank = "8", value = 8 },
  { suit = "hearts", rank = "9", value = 9 },
  { suit = "hearts", rank = "10", value = 10 },
  { suit = "hearts", rank = "Jack", value = 10 },
  { suit = "hearts", rank = "Queen", value = 10 },
  { suit = "hearts", rank = "King", value = 10 },
  { suit = "hearts", rank = "Ace", value = 11 },

  -- Diamonds
  { suit = "diamonds", rank = "2", value = 2 },
  { suit = "diamonds", rank = "3", value = 3 },
  { suit = "diamonds", rank = "4", value = 4 },
  { suit = "diamonds", rank = "5", value = 5 },
  { suit = "diamonds", rank = "6", value = 6 },
  { suit = "diamonds", rank = "7", value = 7 },
  { suit = "diamonds", rank = "8", value = 8 },
  { suit = "diamonds", rank = "9", value = 9 },
  { suit = "diamonds", rank = "10", value = 10 },
  { suit = "diamonds", rank = "Jack", value = 10 },
  { suit = "diamonds", rank = "Queen", value = 10 },
  { suit = "diamonds", rank = "King", value = 10 },
  { suit = "diamonds", rank = "Ace", value = 11 },

  -- Clubs
  { suit = "clubs", rank = "2", value = 2 },
  { suit = "clubs", rank = "3", value = 3 },
  { suit = "clubs", rank = "4", value = 4 },
  { suit = "clubs", rank = "5", value = 5 },
  { suit = "clubs", rank = "6", value = 6 },
  { suit = "clubs", rank = "7", value = 7 },
  { suit = "clubs", rank = "8", value = 8 },
  { suit = "clubs", rank = "9", value = 9 },
  { suit = "clubs", rank = "10", value = 10 },
  { suit = "clubs", rank = "Jack", value = 10 },
  { suit = "clubs", rank = "Queen", value = 10 },
  { suit = "clubs", rank = "King", value = 10 },
  { suit = "clubs", rank = "Ace", value = 11 },

  -- Spades
  { suit = "spades", rank = "2", value = 2 },
  { suit = "spades", rank = "3", value = 3 },
  { suit = "spades", rank = "4", value = 4 },
  { suit = "spades", rank = "5", value = 5 },
  { suit = "spades", rank = "6", value = 6 },
  { suit = "spades", rank = "7", value = 7 },
  { suit = "spades", rank = "8", value = 8 },
  { suit = "spades", rank = "9", value = 9 },
  { suit = "spades", rank = "10", value = 10 },
  { suit = "spades", rank = "Jack", value = 10 },
  { suit = "spades", rank = "Queen", value = 10 },
  { suit = "spades", rank = "King", value = 10 },
  { suit = "spades", rank = "Ace", value = 11 },
}

local suits = { "hearts", "diamonds", "clubs", "spades" }
local ranks = {
  { "2", 2 },
  { "3", 3 },
  { "4", 4 },
  { "5", 5 },
  { "6", 6 },
  { "7", 7 },
  { "8", 8 },
  { "9", 9 },
  { "10", 10 },
  { "Jack", 10 },
  { "Queen", 10 },
  { "King", 10 },
  { "Ace", 11 },
}

--- Generate a standard deck of 52 cards
---@param number_of_decks number Number of decks to be generated
---@return Deck a un-shuffled deck of cards
function M.gen_deck(number_of_decks)
  local deck = {}

  for _ = 1, number_of_decks, 1 do
    for _, suit in ipairs(suits) do
      for _, rank_data in ipairs(ranks) do
        table.insert(deck, {
          suit = suit,
          rank = rank_data[1],
          value = rank_data[2],
        })
      end
    end
  end

  return deck
end

---@param deck Deck a selection of cards
---@return Deck
function M.shuffle(deck)
  for i = #deck, 2, -1 do
    local j = math.random(i)
    deck[i], deck[j] = deck[j], deck[i]
  end
  return deck
end

-- Simple one-line display for each card
---@param cards Deck a selection of cards
---@return string
function M.display_cards(cards)
  for _, card in ipairs(cards) do
    return (card.rank .. " of " .. card.suit)
  end
end

-- Or if you want something fancier with all info:
---@param cards Deck a selection of cards
---@return string
function M.display_cards_detailed(cards)
  for i, card in ipairs(cards) do
    return (string.format("Card %d: %s of %s (value: %d)", i, card.rank, card.suit, card.value))
  end
end

-- If you want to show them all on one line:
---@param cards Deck a selection of cards
---@return string
function M.display_cards_inline(cards)
  local card_strings = {}
  for _, card in ipairs(cards) do
    table.insert(card_strings, card.rank .. " of " .. card.suit)
  end
  return (table.concat(card_strings, ", "))
end

return M
