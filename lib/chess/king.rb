require_relative 'piece'

#
class King < Piece
	attr_accessor :moved
	
	def initialize
		@moved = false
	end

	def possible_positions
		positions = move_once_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
		# HANDLE CASTLING
		# 
	end
end
