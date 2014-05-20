# Class to define the properties and movement of a King
class King < Piece
	attr_accessor :moved

	def initialize(color, position, chessboard)
  	super(color, position, :king, chessboard)
		@moved = false
		@castle_direction = []
	end

  # Determine all directions on a chessboard both Kings can castle to
  # The result of this method is part of the state of a chessgame that
  # is used to check for a draw by threefold repetition
	def get_castle_direction
		@castle_direction = []
		handle_castling([]) unless @moved
		@castle_direction
	end

  # Determine positions a King can go to on a chessboard the King is on
	def possible_positions(castling = nil)
		positions = move_once_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
		return positions if castling 

		handle_castling(positions) unless @moved
		@castle_direction = []
		positions
	end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
	private

  # Determine if a King can castle in positions on it right and/or left
	def handle_castling positions
		king_row = @position[0]
		left_piece  = @chessboard.piece_at([king_row, 0])
		right_piece = @chessboard.piece_at([king_row, 7])
		if left_piece.instance_of?(Rook)  && !left_piece.moved
			add_castling(positions, king_row, :left) 
		end
		if right_piece.instance_of?(Rook) && !right_piece.moved
			add_castling(positions, king_row, :right) 
		end
	end

  # Determine if a King can castle in a direction
	def add_castling(positions, row, direction)
		king_positions = get_positions(direction)
		clear_positions = king_positions[1..-1]
		clear_positions << [row, 1] if direction == :left

		if positions_clear?(clear_positions) && none_attacked?(king_positions)
			positions << king_positions.last
			@castle_direction << direction
		end
	end

  # Determine positions King will traverse during castling move
	def get_positions(direction)
		pos_change = direction == :left ? [0, -1] : [0, 1]
		pass_position = add_positions(@position,     pos_change)
		end_position  = add_positions(pass_position, pos_change)
		[@position.dup, pass_position, end_position]
	end

  # Determine if a group of positions are not attacked by any enemy piece
	def none_attacked?(positions)
		attacked = @chessboard.positions_attacked_by(other_piece, :castling)
		positions.none? { |position| attacked.include?(position) }
	end

  # Determine if a group of positions have no piece on them
	def positions_clear?(positions)
		positions.all? do |position| 
			@chessboard.piece_at(position).color == :clear
		end
	end

end
