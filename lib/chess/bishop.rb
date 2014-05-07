require_relative 'piece'

#
class Bishop < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :bishop, chessboard)
	end

	def possible_positions
		positions_towards([:nw, :ne, :se, :sw])
	end
end
