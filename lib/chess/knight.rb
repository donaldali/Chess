require_relative 'piece'

#
class Knight < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :knight, chessboard)
	end

	def possible_positions
		piece_colors = @chessboard.get_piece_colors

		knight_positions.select do |position| 
			board_position?(position) && piece_colors[position[0]][position[1]] != @color
		end
	end

  # Generate all positions a knight can move to (legal and illegal)
  def knight_positions
  	positions = []
  	pair = { 1 => [2, -2], 2 => [1, -1] }
  	row_change = [-2, -1, 1, 2]
  	row_change.each do |change|
  		positions << add_positions(@position, [change, pair[change.abs][0]])
  		positions << add_positions(@position, [change, pair[change.abs][1]])
  	end
  	positions
  end
end
