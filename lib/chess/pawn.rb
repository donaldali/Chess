# Class to define the properties and movement of a Pawn
class Pawn < Piece
	attr_accessor :moved

	def initialize(color, position, chessboard)
  	super(color, position, :pawn, chessboard)
		@moved = false
	end
	
  # Determine positions a Pawn can go to on a chessboard the Pawn is on
	def possible_positions
		piece_colors = @chessboard.get_piece_colors

		positions = []
		row_change = (@color == :white) ? -1 : 1
		forward_positions( piece_colors, positions, row_change)
		diagonal_positions(piece_colors, positions, row_change)
		positions
	end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
	private

  # Determine positions a Pawn can go to straight in front of it
	def forward_positions(piece_colors, positions, row_change)
		next_position = add_positions(@position, [row_change, 0])
		if board_position?(next_position) && 
			 piece_colors[next_position[0]][next_position[1]] == :clear
			positions << next_position
			next_position = add_positions(next_position, [row_change, 0])
			if !@moved && board_position?(next_position) && 
				            piece_colors[next_position[0]][next_position[1]] == :clear
			  positions << next_position
			end
		end
	end

  # Determine positions a Pawn can go to in its forward diagonals
	def diagonal_positions(piece_colors, positions, row_change)
		one_diagonal_position(piece_colors, positions, row_change, -1)
		one_diagonal_position(piece_colors, positions, row_change,  1)
	end

  # Determine position a Pawn can go to in one forward diagonal
	def one_diagonal_position(piece_colors, positions, row_change, col_change)
		next_position = add_positions(@position, [row_change, col_change])
		if board_position?(next_position) && 
			 piece_colors[next_position[0]][next_position[1]] == other_piece
			positions << next_position
		end
		# Check for en passant
		if board_position?(next_position) && 
			 next_position == @chessboard.en_passant_position
			positions << next_position
		end
	end
end
