# Reward System

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
