require_relative 'piece'

#
class Queen < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :queen, chessboard)
	end

	def possible_positions
		positions_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
	end
end
