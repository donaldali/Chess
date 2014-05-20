require './lib/chess/piece'
require './lib/chess/bishop'
require './lib/chess/chessboard'
require './lib/chess/chess_controller'
require './lib/chess/chess_game'
require './lib/chess/chess_module'
require './lib/chess/king'
require './lib/chess/knight'
require './lib/chess/pawn'
require './lib/chess/queen'
require './lib/chess/rook'
require 'yaml'
include Chess

chess_controller = ChessController.new
chess_controller.run
