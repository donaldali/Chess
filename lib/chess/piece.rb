#
class Piece
	attr_accessor :color, :position, :type, :chessboard

	SIZE = 8
	DIR_CHANGE = { north: [-1, 0], ne: [-1, 1], east: [0,  1], se: [1,   1],
		             south: [ 1, 0], sw: [1, -1], west: [0, -1], nw: [-1, -1] }

	def move_once_towards(directions)
		# ***************************
		# *** REPLACE piece_color ***
		# ***************************
		piece_colors = @chessboard

	  positions = []
	  directions.each do |direction|
	  	next_position = add_positions(@position, DIR_CHANGE[direction])
	  	if board_position?(next_position) &&
	  	   piece_colors[next_position[0]][next_position[1]] != @color
	  		positions << next_position
	  	end
	  end
	  positions
	end

	def positions_towards(directions)
		# ***************************
		# *** REPLACE piece_color ***
		# ***************************
		piece_colors = @chessboard

	  positions = []
	  directions.each do |direction|
	  	next_position = add_positions(@position, DIR_CHANGE[direction])
	  	while board_position?(next_position)
	  		case piece_colors[next_position[0]][next_position[1]]
	  		when nil    then positions << next_position # no piece
	  		when @color then break                      # player's piece
	  		else positions << next_position; break      # opponent's piece
	  		end
	  		next_position = add_positions(next_position, DIR_CHANGE[direction])
	  	end
	  end
	  positions
	end

	def board_position?(position)
		position[0].between?(0, SIZE - 1) && position[1].between?(0, SIZE - 1)
	end

	def add_positions(position1, position2)
		[position1[0] + position2[0], position1[1] + position2[1]]
	end

	def subtract_positions(position1, position2)
		[position1[0] - position2[0], position1[1] - position2[1]]
	end

	def other_piece
		@color == :white ? :black : :white
	end
end