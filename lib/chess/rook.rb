require_relative 'piece'

#
class Rook < Piece
	attr_accessor :moved

	def initialize(color, position, chessboard)
	 	super(color, position, :rook, chessboard)
		@moved = false
	end

	def possible_positions
		positions_towards([:north, :south, :east, :west])
	end
end
