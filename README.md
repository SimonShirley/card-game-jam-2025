# Absolute Trash - A Card Game for the Commodore 64

Unlike other game jam submissions, this one is Absolute Trash!

Absolute Trash is a card game for the Commodore 64, based on the real card game, Trash or Garbage, written in BASIC.

This game is a submission for the [Retro Programmers Inside (RPI) and Phaze101 game jam](https://itch.io/jam/cardgame).

The idea of the game is to complete your bank of cards, Ace to 10, before the computer. With the exception of playing wild card Jacks, this game is mostly based on the luck of the card shuffle.


## How to Play

On your turn, play starts either by drawing the top card from the stack pile, or from the discard pile if you currently have that card face down in your card bank and discard pickups are enabled in the menu.

Upon drawing a card, this card is placed in your card bank, replacing the face down card. The face down card is flipped face up and is now the current card in play.

If the current card can be placed in your card bank where the bank card is face down, the current card is placed in the bank, the bank card is flipped face up and becomes the next card in play.

Your turn continues until you reveal a card that you cannot play.

Unplayable cards are cards where there is already a face up card in that bank position, you've drawn a card for which there isn't a bank position (see Number of Rounds for a Win menu option), or the card in play is a Queen or a King. If wild cards are disabled, the Jack would also be an unplayable card.

This card is then placed on the discard pile and your turn is over.

Play alternates between the player and the computer until all of a player's bank cards have been turned face up.

The suit of the card bears no relevance in this game, only the rank of the card.

In-game instructions and rules can be read by pressing **I** at the game mode menu.


## Controls

This game is played using the keyboard only.

The cursor is moved using the **cursor keys** (up, down, left and right), the **WASD** keys (W-Up, A-Left, S-Down, D-Right) and the **RETURN** key.

The keys move the highlighted frame around the relevant screen areas.


## Game Mode / Options
### Discard Pickup

This mode gives you to option to draw the most recent card that the opponent discarded at the end of their turn.

By the rules of Trash, discard pickups are usually allowed. Disabling this mode makes for a longer game.

Press F1 to toggle this option in the menu.


### Jacks as Wild Cards

With this mode enabled, the Jack card can be played as if it were any card between Ace and 10. Jacks can also be re-played if the real value of a card banked is later drawn.

By the rules of Trash, Jacks are normally wild cards. Disabling this mode makes for a longer game.

Press F3 to toggle this option in the menu.


### Number of Rounds for a Win

This is the number of rounds that the player or the computer will need to win in order for the game to come to a complete conclusion.

According to the rules of Trash, the game should continue until a player wins 10 rounds, with each round removing the highest card from their bank when a round is won - Ace to 10, then Ace to 9, then Ace to 8, and so on until the player is only playing for an Ace card. However, this makes the game rather long, so this mode shortens the number of winning rounds to the specified amount.

Press F5 to raise the amount and F7 to lower the amount of rounds to win by in the menu.


## Special Thanks

These can be read in-game by pressing **C** at the game mode menu.

Thanks to [Retro Programmers Inside (RPI)](https://rpinside.itch.io/) and [Phaze101](https://twitch.tv/Phaze1o1) for hosting the game jam.
https://itch.io/jam/cardgame

**John McLeod** and [**Pagat.com**](https://www.pagat.com) for hosting and maintaining such a wonderful resource online, containing the rules to many card games, and for making them freely available.

The rules to this game can be found at: https://www.pagat.com/patience/trash.html

[DeadSheppy](https://twitch.tv/DeadSheppy) for putting up with all my ramblings on how this game was made, the thought processes into the decision making, for helping to test the game, asking questions and for being supportive all the way through the process.

The source code was written in [Visual Studio Code](https://code.visualstudio.com/), using the [VS64 extension](https://github.com/rolandshacks/vs64) by Roland Shacks.


