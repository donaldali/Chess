# Class to define the properties and movement of a Rook
class Rook < Piece
	attr_accessor :moved

	def initialize(color, position, chessboard)
	 	super(color, position, :rook, chessboard)
		@moved = false
	end

  # Determine positions a Rook can go to on a chessboard the Rook is on
	def possible_positions
		positions_towards([:north, :south, :east, :west])
	end
end
