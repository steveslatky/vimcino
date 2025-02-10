# 🃏 Blackjack (21)

<!--toc:start-->
- [🃏 Blackjack (21)](#🃏-blackjack-21)
  - [Objective](#objective)
    - [Card Values](#card-values)
    - [Gameplay Flow](#gameplay-flow)
<!--toc:end-->

A classic casino card game where players compete against the dealer to reach the closest hand value to **21** without going over.

## Objective
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

