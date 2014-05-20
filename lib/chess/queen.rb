# Class to define the properties and movement of a Queen
class Queen < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :queen, chessboard)
	end

  # Determine positions a Queen can go to on a chessboard the Queen is on
	def possible_positions
		positions_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
	end
end
