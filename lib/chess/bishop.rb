# Class to define the properties and movement of a Bishop
class Bishop < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :bishop, chessboard)
	end

  # Determine positions a Bishop can go to on a chessboard the Bishop is on
	def possible_positions
		positions_towards([:nw, :ne, :se, :sw])
	end
end
