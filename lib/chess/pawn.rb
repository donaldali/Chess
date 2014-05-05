require_relative 'piece'

#
class Pawn < Piece
	attr_accessor :moved

	def initialize
		@moved = false
	end
	
	def possible_positions
		# ***************************
		# *** REPLACE piece_color ***
		# ***************************
		piece_colors = @chessboard

		positions = []
		row_change = @color == :white ? -1 : 1
		forward_positions( piece_colors, positions, row_change)
		diagonal_positions(piece_colors, positions, row_change)
		positions
	end

	def forward_positions(piece_colors, positions, row_change)
		next_position = add_positions(@position, [row_change, 0])
		if board_position?(next_position) && piece_colors[next_position[0]][next_position[1]].nil?
			positions << next_position
			next_position = add_positions(next_position, [row_change, 0])
			if !@moved && board_position?(next_position) && 
				            piece_colors[next_position[0]][next_position[1]].nil?
			  positions << next_position
			end
		end
	end

	def diagonal_positions(piece_colors, positions, row_change)
		one_diagonal_position(piece_colors, positions, row_change, -1)
		one_diagonal_position(piece_colors, positions, row_change,  1)
	end

	def one_diagonal_position(piece_colors, positions, row_change, col_change)
		next_position = add_positions(@position, [row_change, col_change])
		if board_position?(next_position) && piece_colors[next_position[0]][next_position[1]] == other_piece
			positions << next_position
		end
		# Check for en passant
		# if board_position?(next_position) && next_position == chessboard.en_passant_position
		# 	positions << next_position
		# end
	end
end
