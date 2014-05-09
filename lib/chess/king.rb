require_relative 'piece'

#
class King < Piece
	attr_accessor :moved

	def initialize(color, position, chessboard)
  	super(color, position, :king, chessboard)
		@moved = false
		@castle_direction = []
	end

	def possible_positions(castling = nil)
		positions = move_once_towards([:north, :south, :east, :west, :nw, :ne, :se, :sw])
		return positions if castling 

		handle_castling(positions) unless @moved
		@castle_direction = []
		positions
	end

	def handle_castling positions
		king_row = @position[0]
		left_piece  = @chessboard.squares[king_row][0].piece
		right_piece = @chessboard.squares[king_row][7].piece
		if left_piece.instance_of?(Rook)  && !left_piece.moved
			add_castling(positions, king_row, :left) 
		end
		if right_piece.instance_of?(Rook) && !right_piece.moved
			add_castling(positions, king_row, :right) 
		end
	end

	def add_castling(positions, row, direction)
# puts "ADDING: #{self}"
		king_positions = get_positions(direction)
		clear_positions = king_positions[1..-1]
		clear_positions << [row, 1] if direction == :left

		if positions_clear?(clear_positions) && none_attacked?(king_positions)
			positions << king_positions.last
			@castle_direction << direction
		end
	end

	def get_positions(direction)
		pos_change = direction == :left ? [0, -1] : [0, 1]
		pass_position = add_positions(@position,     pos_change)
		end_position  = add_positions(pass_position, pos_change)
		[@position.dup, pass_position, end_position]
	end

	def none_attacked?(positions)
		# attacked = @chessboard.positions_attacked_by(other_piece)
		attacked = @chessboard.positions_attacked_by(other_piece, :castling)
		positions.none? { |position| attacked.include?(position) }
	end

	def positions_clear?(positions)
		positions.all? do |position| 
			@chessboard.piece_at(position).color == :clear
		end
	end

	def get_castle_direction
		@castle_direction = []
		handle_castling([]) unless @moved
		@castle_direction
	end
end
