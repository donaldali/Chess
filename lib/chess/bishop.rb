require_relative 'piece'

#
class Bishop < Piece
	def possible_positions
		positions_towards([:nw, :ne, :se, :sw])
	end
end
