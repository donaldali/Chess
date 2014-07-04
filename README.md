# Chess

This is a two-player CLI Chess game implemented using [test-driven development](http://en.wikipedia.org/wiki/Test-driven_development "Test Driven Development") for the [Final Project: Chess](http://www.theodinproject.com/ruby-programming/ruby-final-project "Final Project: Chess") of the Ruby course of [The Odin Project](http://www.theodinproject.com/home "The Odin Project").

This game follows the [Laws of Chess](http://www.fide.com/component/handbook/?id=171&view=article "Laws of Chess") as given by [The Fédération internationale des échecs (FIDE)](http://www.fide.com/index.php "World Chess Federation") or World Chess Federation. Wikipedia provides a very good summary of the [rules of chess](http://en.wikipedia.org/wiki/Chess#Rules "Chess Rules"), sufficient for understanding some of the obscure chess rules you might be unfamiliar with.

To play the game, enter `$ rake play` or `$ ruby lib/chess.rb` from the root directory (chess). You can run the test suite with `$ rake` from the same root directory.

- **Note:** Windows users should `$ gem install win32console` to get the appropriate color display of the gameboard.

## Gameboard

The game is played on a standard 8 by 8 chessboard. The initial chessboard is shown below:

```
    a  b  c  d  e  f  g  h  
  8 ♜  ♞  ♝  ♛  ♚  ♝  ♞  ♜  8
  7 ♟  ♟  ♟  ♟  ♟  ♟  ♟  ♟  7
  6                         6
  5                         5
  4                         4
  3                         3
  2 ♙  ♙  ♙  ♙  ♙  ♙  ♙  ♙  2
  1 ♖  ♘  ♗  ♕  ♔  ♗  ♘  ♖  1
    a  b  c  d  e  f  g  h  
```

The numbers (1 - 8) and letters (a - h) around the board are used to specify desired game moves.

## Game Moves

A move is entered as two positions separated by a space and/or a comma, or nothing. The following are valid ways to move a white knight on the first game move:

- `b1 c3`
- `b1,c3`
- `b1, c3`
- `b1c3`

#### Illegal moves

The game is designed to detect various types of wrong inputs and provide helpful hints for each.  The following inputs will generate different error messages: `a1 a2 a3`, `a1 a22`, `a1 a9`, and `a1 k1`.

After two valid board positions are detected, further checks are made (and appropriate hints provided) to ensure that a player is attempting to move from a postion with their piece to a position that piece can move to, given the board configuration. Perhaps the most useful hint provided is when a player attempts what appears to be a legal move (like moving a bishop diagonally) but doesn't realize that the move would leave their king in check. 

#### Special moves

All special moves in a chess game ([castling](http://en.wikipedia.org/wiki/Castling "Castling"), [en passant](http://en.wikipedia.org/wiki/En_passant "En passant"), <a href="http://en.wikipedia.org/wiki/Promotion_(chess)" title="Promotion">promotion</a>, and a pawn's double step on its first move) are recognized and allowed during game play.

## Game Play

Game play alternates between two players as one would expect with only valid moves being allowed. In addition to the helpful hints provided for illegal moves described above,  a player is warned whenever an opponent's moves places their king in check.  Play continues until an end game condition occurs.

## End Game

According to Article 5 of the [Laws of Chess](http://www.fide.com/component/handbook/?id=171&view=article "Laws of Chess"), there are seven ways for the completion of a chess game. They are:

- **Win**
  - [Checkmate](http://en.wikipedia.org/wiki/Checkmate "Checkmate")
  - [Resignation](http://en.wikipedia.org/wiki/List_of_chess_terms#Resign "Resignation")
- **Draw**
  - [Stalemate](http://en.wikipedia.org/wiki/Stalemate "Stalemate")
  - Dead Position or [Impossibility of Checkmate](http://en.wikipedia.org/wiki/Glossary_of_chess#Insufficient_material "Insuffient material to checkmate") 
  - [Agreement](http://en.wikipedia.org/wiki/Draw_by_agreement "Draw by Agreement")
  - [Threefold Repetition](http://en.wikipedia.org/wiki/Threefold_repetition "Threefold Repetition") or Repetition of Position
  - [Fifty Move Rule](http://en.wikipedia.org/wiki/Fifty-move_rule "Fifty Move Rule")

All seven ways are implemented in this game. The game is ended as soon as a checkmate, stalemate, or dead position is detected. For the other four end game possibilities, some player interaction is required. The menu for these end game possibilities, which can be accessed by entering `options` or `o` from the standard prompt, are shown below:

```
In Game Options for Foo<white>
==============================
1. Resign (Loss for Foo)
2. Offer Draw to Bar
3. Claim Draw by Threefold Repetition
4. Claim Draw by Fifty-Move Rule
5. Save (with Bar's consent)
6. Exit
Select an option (1 - 6): 
```

A resignation results in an instant loss; the other three draw options requires the player to still indicate their next move. Both claims of a draw are checked before and after the claimant's indicated next move.

## Game Saves

As the menu above shows, a player may save a game from the In Game Options (with the consent of their opponent). Management of saved games (loading and playing, deleting, listing names of) can be done from the main menu. 
You may save a game and continue at a later time of your convenience for multiple days of fun ☺.
