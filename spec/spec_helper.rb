require 'chess/piece'
require 'chess/bishop'
require 'chess/chessboard'
require 'chess/chess_controller'
require 'chess/chess_game'
require 'chess/chess_module'
require 'chess/king'
require 'chess/knight'
require 'chess/pawn'
require 'chess/queen'
require 'chess/rook'
require 'yaml'
include Chess

def clear_board
  clear_board = Chessboard.new
  (0..Chess::SIZE - 1).each do |row|
    (0..Chess::SIZE - 1).each do |col|
      clear_board.clear_square([row, col])
    end
  end
  clear_board
end

def castling_setup
  chessboard.clear_square([7, 1])
  chessboard.clear_square([7, 2])
  chessboard.clear_square([7, 3])
  chessboard.clear_square([7, 5])
  chessboard.clear_square([7, 6])

  chessboard.clear_square([0, 1])
  chessboard.clear_square([0, 2])
  chessboard.clear_square([0, 3])
  chessboard.clear_square([0, 5])
  chessboard.clear_square([0, 6])
end
