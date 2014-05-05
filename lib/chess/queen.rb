require_relative 'piece'

#
class Queen < Piece
	def possible_positions
		positions_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
	end
end
