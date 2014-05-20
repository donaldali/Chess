# Class to define the properties and movement of a Knight
class Knight < Piece
	def initialize(color, position, chessboard)
  	super(color, position, :knight, chessboard)
	end

  # Determine positions a Knight can go to on a chessboard the Knight is on
	def possible_positions
		piece_colors = @chessboard.get_piece_colors

		knight_positions.select do |position| 
			board_position?(position) && piece_colors[position[0]][position[1]] != @color
		end
	end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
  private

  # Generate all positions a Knight can move to (legal and illegal)
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
