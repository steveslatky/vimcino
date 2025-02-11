
# 🎮 Vimcino - Neovim Casino! 

<!--toc:start-->
- [🎮 Vimcino - Neovim Casino!](#🎮-vimcino-neovim-casino)
  - [Features](#features)
  - [Installation](#installation)
    - [[Lazy.nvim](https://github.com/folke/lazy.nvim)](#lazynvimhttpsgithubcomfolkelazynvim)
    - [[Vim Plug](https://github.com/junegunn/vim-plug)](#vim-plughttpsgithubcomjunegunnvim-plug)
    - [[Mini Deps](https://github.com/echasnovski/mini.deps)](#mini-depshttpsgithubcomechasnovskiminideps)
  - [Commands](#commands)
  - [Games](#games)
    - [Deathroll](#deathroll)
      - [Core Rules:](#core-rules)
    - [🃏 Blackjack (21)](#🃏-blackjack-21)
      - [Objective](#objective)
    - [Card Values](#card-values)
    - [Gameplay Flow](#gameplay-flow)
<!--toc:end-->

Need a little break to gamble your life savings away?! Well stop on in to the vimcino where we will be happy 
to take the weight of all that virtual cash off your hands!

![Demo GIF](./assets/demo.gif) 

## Features

- 🕹️ **In-Editor Games** (Deathroll, Blackjack, maybe more in the future!)
- 🏆 **Game Statistics Tracking** (Wins/Losses/Currency)
- 💰 **Virtual Currency System** (That does nothing!)
- 🔄 **Save File Persistence** 
- 🎆 **Reward System** If your mind is so broken you need to gameify everything! 

## Installation

Using your favorite package manager:

### [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "steveslatky/vimcino",
  --- optional custom options
  ---@field vimcino.Config
	opts = {
    -- Change up the functionally if wanted
	},
},
```

### [Vim Plug](https://github.com/junegunn/vim-plug)
  ```lua
Plug 'your-username/vimcino'
lua require("vimcino").setup(opts)
```

### [Mini Deps](https://github.com/echasnovski/mini.deps)
```lua
add({
  source = 'neovim/nvim-lspconfig',
  config = function()
    -- Plugin configuration
    ---@field vimcino.Config
    require('vimcino').setup(opts)
  end
})
```

## Configuration

```lua
M.default_config = {
  stats = {
    file_loc = nil, -- This will store it in the plugin directory
  },
  blackjack = {
    number_of_decks = 1,
  },
  rewards = {
    enable = false,
    goal = 10000,
    value = 100,
    notify = false,
  },
  ```

## Commands 

```vim
:Vimcino " Open the game selector 
:VimcinoStats " View your stats
```

## Games 

### Deathroll 


Deathroll is a high-stakes dice game of chance and diminishing odds, popularized in World of Warcraft. Players take turns rolling a virtual die with ever-shrinking numbers until one participant lands on 1 and loses the round.

#### Core Rules:
Starting Number: Players agree on an initial number (e.g., 1000)

Turn Sequence:

Player 1 rolls between 1 and starting number
Computer then rolls between 1 and Player 1's result
This continues until someone rolls 1
Loss Condition: The player who rolls 1 loses the round


### 🃏 Blackjack (21)

A classic casino card game where players compete against the dealer to reach the closest hand value to **21** without going over.

#### Objective
- Beat the dealer by having:
  - A higher hand value without exceeding 21
  - Letting the dealer bust (exceed 21)
  - A natural blackjack (Ace + 10-value card) unless dealer also has one

### Card Values
| Cards | Value |
|-------|-------|
| 2-10  | Face value |
| J, Q, K | 10 |
| A | 1 **or** 11 (player's choice) |

### Gameplay Flow
1. **Place Bet**: Risk virtual currency
2. **Initial Deal**: 
   - Player receives 2 face-up cards
   - Dealer gets 1 face-up and 1 face-down card
3. **Player Actions**:
   - **Hit**: Take another card
   - **Stand**: Keep current hand
4. **Dealer Reveal**: Dealer reveals hidden card and draws until reaching 17+
5. **Outcome**:
   - **Win**: 1:1 payout (3:2 for natural blackjack)
   - **Lose**: Forfeit bet
   - **Push**: Tie (return bet)


## Reward System

Gives you currency for pressing enough keys! 

According to my middle manager, key presses is the ultimate form of productivity. So you should be rewarded with 
some fake money to make you the most productive! You have full control how this system works for you.


```lua
default_opts = {
  rewards = {
    enable = false, -- Won't work if false 
    goal = 10000, -- Number of key presses needed to be rewarded
    value = 100,  -- Amount you get rewarded with
    notify = false, -- lets you know every time you met the goal
  },
```
