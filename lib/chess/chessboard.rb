# Class to model the state of a chessboard an operations on the chessboard
# during a game of chess
class Chessboard
	Square = Struct.new(:color, :position, :piece)

	PIECES = { white: { king:   "\u2654", queen:  "\u2655", rook: "\u2656",
	                    bishop: "\u2657", knight: "\u2658", pawn: "\u2659" },
	           black: { king:   "\u265a", queen:  "\u265b", rook: "\u265c",
	                    bishop: "\u265d", knight: "\u265e", pawn: "\u265f" },
	           clear: { } }

  attr_accessor :en_passant_position, :no_capture_or_pawn_moves, :squares, :players

  def initialize(players = { white: "White Player", black: "Black Player" })
  	@squares = generate_squares
  	set_squares_color_position
    @players = players
    reset_board
  end

  # Reset the hessboard to its initial state
  def reset_board
    reset_square_pieces
    @en_passant_position = nil
    @no_capture_or_pawn_moves = 0
  end

  # Get the piece at a position of the chessboard
  def piece_at(position)
    square_at(position).piece
  end

  # Set the square at a given position to contain a piece
  def set_square(position, piece)
    piece.position = [position[0], position[1]]
    @squares[position[0]][position[1]].piece = piece
  end

  # Set a square to have no piece
  def clear_square(position)
    piece = Piece.new(:clear)
    @squares[position[0]][position[1]].piece = piece
  end

  # Get an array representation of the colors of pieces at all squares of
  # the chess board.  This method returns an 8 X 8 array of piece colors
  # which is used by a Piece object to determine what positions on the 
  # chessboard it can move to
  def get_piece_colors
    @squares.map do |row|
      row.map { |square| square.piece.color }
    end
  end

  # Perform all the necessary actions to move a piece from one location to another.
  # This method does not verify the move, so all verification must be done to 
  # ensure that a move is legal prior to calling this method 
  def move(from, to)
    to_piece = move_piece(from, to)
    update_moved(to)
    return if en_passant_capture(to)

    set_en_passant_position(from, to)
    update_no_capture_or_pawn_moves(to_piece, to)
    handle_promotion(to)
    castling_move(from, to)
  end

  # Move a piece from one position to another and return the piece that was 
  # at the position moved to
  def move_piece(from, to)
    to_piece = piece_at(to)
    set_square(to, piece_at(from))
    clear_square(from)
    to_piece
  end

  # Determine all the positions all the pieces of a player is attacking on
  # a chessboard.  This method is used to ensure that a move does not result
  # in a King being in check.  The castling parameter here is used to prevent
  # an infinite loop that results if both kings are eligible to castle
  def positions_attacked_by(player, castling = nil)
    attacked = []
    player_pieces(player).each do |piece|
      if castling && piece.instance_of?(King)
        attacked.concat(piece.possible_positions(castling))
      else
        attacked.concat(piece.possible_positions)
      end
    end
    attacked.uniq
  end

  # Determine if a player's King is in check (under attack by an opponent's piece)
  def check?(player)
    attacked_positions = positions_attacked_by(Chess.other_player(player))
    attacked_positions.include?(king_position(player))    
  end

  # Determine if a player has been checkmated
  def checkmate?(player)
    no_valid_move?(player) && check?(player)
  end

  # Determine if a stalemate condition has occured
  def stalemate?(player)
    no_valid_move?(player) && !check?(player)
  end

  # Determine if one of a number of conditions that exist which mean that no
  # player could checkmate the other
  def checkmate_impossible?
    black_type_count = type_count(:black)
    white_type_count = type_count(:white)

    return false if black_type_count[:other] > 0 || white_type_count[:other] > 0
    return false if black_type_count[:knight] + white_type_count[:knight] > 1
    insufficient_material?(black_type_count, white_type_count)
  end

  # Determine what position a player's king currently occupies
  def king_position(player)
    player_pieces(player).find{ |piece| piece.type == :king }.position
  end

  # Determine if a chessboard position contains no piece
  def clear_position?(position)
    piece_at(position).color == :clear
  end

  # Determine which directions the Kings can castle on the current board
  # The first element of the return value is an array stating if the black 
  # king can castle to its right and/or left; the second element is a
  # similar representation for the white king
  def get_castle_direction
    black_king = piece_at(king_position(:black))
    white_king = piece_at(king_position(:white))
    [black_king.get_castle_direction, white_king.get_castle_direction]
  end

  # Generate the state of the chessboard. This state is determined mainly by
  # the pieces at each chessboard position, but also includes what position an
  # en passant capture may happen (if any) and where both kings are allowed 
  # to castle
  def board_state
    pieces = []
    @squares.each do |row|
      row.each do |square|
        unless square.piece.color == :clear
          piece = square.piece
          pieces << [piece.color, piece.type, piece.position]
        end
      end
    end
    [pieces, @en_passant_position, get_castle_direction]    
  end

  # Display the chessboard from the point of view of a given player. The
  # board is first represented in a string and then formatted based on
  # the player whose point of view is to be displayed from
  def display_board(player = :white)
    board_str = "\t  a  b  c  d  e  f  g  h  \n\t"
    ranks = [8, 7, 6, 5, 4, 3, 2, 1]
    @squares.each_with_index do |row, row_index|
      board_str += "#{ranks[row_index]}"
      row.each do |square|
        board_str += Chess.colorize(" #{PIECES[square.piece.color].fetch(square.piece.type, 'X')} ",
                                    chessboard_color_code(square.color, square.piece.color))
      end
      board_str += " #{ranks[row_index]}\n\t"
    end
    board_str += "  a  b  c  d  e  f  g  h  \n"

    Chess.display_message player_view(board_str, player)
  end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
  private

  # Create all blank squares for the chessboard
  def generate_squares
  	squares = []
  	Chess::SIZE.times do 
  		new_row = []
  		Chess::SIZE.times { new_row << Square.new }
  		squares << new_row
  	end
  	squares
  end

  # Set the colors (light or dark) of all chessboard squares
  def set_squares_color_position
  	switch_color = ->(color){ color == :light ? :dark : :light }
  	color = :light
  	@squares.each_with_index do |row, row_index|
  		row.each_with_index do |square, col_index|
  			square.color = color 
  			color = switch_color.call(color)
  			square.position = [row_index, col_index] 
  		end
  		color = switch_color.call(color)
  	end
  end

  # Reset the pieces of the chessboard to their initial configuartion
  def reset_square_pieces
  	set_end_rows
  	set_pawn_rows
  	set_blank_rows
  end

  # Reset the top and bottom chessboard rows (ranks) to their initial configuration
  def set_end_rows
  	set_an_end_row(:black, 0, [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook])
  	set_an_end_row(:white, 7, [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook])
  end

  # Reset the top or bottom chessboard row (rank) to its initial configuration
  def set_an_end_row(piece_color, row, piece_types)
  	(0..Chess::SIZE - 1).each do |col|
  		piece = Piece.create(piece_color, [row, col], piece_types[col], self)
  		@squares[row][col].piece = piece
  	end
  end

  # Reset the rows that initially contain pawns to have pawns
  def set_pawn_rows
  	set_a_pawn_row(:black, 1)
  	set_a_pawn_row(:white, 6)
  end

  # Reset a row that initially contains pawns to have pawns
  def set_a_pawn_row(piece_color, row)
  	(0..Chess::SIZE - 1).each do |col|
  		piece = Piece.create(piece_color, [row, col], :pawn, self)
  		@squares[row][col].piece = piece
  	end
  end

  # Reset the rows that are initially blank to have no pieces
  def set_blank_rows
  	(2..5).each do |row|
  		set_a_blank_row(row)
  	end
  end

  # Reset a row that is initially blank to have no pieces
  def set_a_blank_row(row)
  	(0..Chess::SIZE - 1).each do |col|
  		piece = Piece.new(:clear)
  		@squares[row][col].piece = piece
  	end
  end

  # Get an array containing all the pieces a player has on the chessboard
  def player_pieces(player)
  	@squares.map do |row|
  		row.map { |square| square.piece }
  	end.flatten.select { |piece| piece.color == player }
  end

  # Get the square at a position of the chessboard
  def square_at(position)
  	@squares[position[0]][position[1]]
  end

  # Determine if a player has no valid move (which leads to an end game situation)
  def no_valid_move?(player)
    player_pieces(player).all? { |piece| piece.move_positions.empty? }
  end

  # Helper for checkmate_impossible which checks if the types of pieces on a 
  # chessboard are too few and hence create a checkmate impossible situation
  def insufficient_material?(black_type_count, white_type_count)
    black_count = black_type_count.values.reduce(:+)
    white_count = white_type_count.values.reduce(:+)

    if black_count == 1 && white_count == 1 # King vs King
      true
    elsif (black_count == 1 && white_count == 2) || (white_count == 1 && black_count == 2)
      true
    else
      all_bishops_on_same_square_color?
    end
  end

  # Determine all bishops on a chessboard (for both players) are on squares of 
  # the same color.  This may indicate a checkmate impossible situation
  def all_bishops_on_same_square_color?
    bishop_squares = []
    @squares.each do |row|
      row.each do |square|
        bishop_squares << square if square.piece.type == :bishop
      end
    end
    square_color = bishop_squares.first.color
    bishop_squares.all? { |bishop_square| bishop_square.color == square_color }
  end

  # Count the number of certain pieces a player has on the chessboard. This is
  # used to determine if a checkmate impossible situation exists
  def type_count player
    count = { knight: 0, bishop: 0, king: 0, other: 0 }
    player_pieces(player).each do |piece|
      case piece.type
      when :knight then count[:knight] += 1
      when :bishop then count[:bishop] += 1
      when :king   then count[:king]   += 1
      else count[:other] += 1
      end
    end
    count
  end

  # Move the Rook to complete a castling move, if a castling move was performed
  def castling_move(from, to)
    move_col_change = subtract_positions(from, to)[1].abs
    if (piece_at(to).type == :king && move_col_change == 2)
      rook_from_col, rook_to_col = (to[1] == 2) ? [0, 3] : [7, 5]
      move_piece([to[0], rook_from_col], [to[0], rook_to_col])
      Chess.display_message "#{@players[piece_at(to).color]} just performed a castling move"
    end
  end

  # If a pawn reaches the opposite rank promote it to a piece type of the
  # player's choosing
  def handle_promotion position
    row = position[0]
    if (piece_at(position).type == :pawn && (row == 0 || row == 7))
      display_board
      old_piece = piece_at(position)
      new_piece_type = get_new_piece_type old_piece.color
      new_piece = Piece.create(old_piece.color, old_piece.position, 
                               new_piece_type, old_piece.chessboard)
      set_square(position, new_piece)
    end
  end

  # Get the type of piece the player's pawn will be promoted to
  def get_new_piece_type player
    options = %w(Queen Bishop Knight Rook)
    options_title = "New Piece Type"
    prompt = "please choose the piece that your pawn will be promoted to"
    Chess.display_message "#{@players[player]}, " + prompt

    choice = Chess.get_option_choice(options, options_title)
    options[choice - 1].downcase.to_sym
  end

  # Increment or reset the count of no capture or pawn moves depending on last move
  def update_no_capture_or_pawn_moves(to_piece, to)
    if (to_piece.color != :clear || piece_at(to).type == :pawn)
      @no_capture_or_pawn_moves = 0
    else
      @no_capture_or_pawn_moves += 1
    end    
  end

  # Set the position where a pawn may capture another pawn en passant.
  # This position is set when a pawn advances two squares on its first move;
  # the square that was advanced over is the en passant position
  def set_en_passant_position(from, to)
    move_row_change = subtract_positions(from, to)[0].abs
    if (piece_at(to).type == :pawn && move_row_change == 2)
      en_passant_position_row = (to[0] == 3) ? 2 : 5
      @en_passant_position = [en_passant_position_row, to[1]]
    else
      @en_passant_position = nil
    end
  end

  # Indicate that a King, Rook, or Pawn has moved. These pieces each have a
  # special move they can execute on their first move.
  def update_moved position
    moved_piece = piece_at(position)
    case moved_piece.type
    when :king, :rook, :pawn then moved_piece.moved = true
    end    
  end

  # Capture a pawn en passant (if the conditions exist) and update all other
  # necessary state variables
  def en_passant_capture(to)
    return unless (to == @en_passant_position && piece_at(to).type == :pawn)

    en_passant_capture_row = (to[0] == 2) ? 3 : 4
    en_passant_capture_position = [en_passant_capture_row, to[1]]

    clear_square(en_passant_capture_position)
    Chess.display_message "#{@players[piece_at(to).color]} just captured en passant"
    @en_passant_position = nil
    @no_capture_or_pawn_moves = 0
  end

  # Determine position from subtraction of the rows and columns of two positions
  def subtract_positions(position1, position2)
    [position1[0] - position2[0], position1[1] - position2[1]]
  end

  # Format the string for the chessboard for a player. If the board is to be
  # displayed for the black player, the rows (or ranks) of the board are
  # reversed, and then for each row/rank the columns (or files) are reversed.
  # The resulting board is such that the black player advances her/his pieces
  # upwards at the start of the game.
  def player_view(board_str, player)
    return board_str.gsub('X', ' ') if player == :white

    black_view = board_str.split("\n").reverse.map do |row|
      if row.include?('h')
        "\t  h  g  f  e  d  c  b  a"
      else
        row[0..1] + row[2..-3].split("\e[0m").reverse.join("\e[0m") + "\e[0m" + " #{row[-1]}"
      end
    end.join("\n")
    black_view.gsub('X', ' ')
  end

  # Set the colors for the black and white pieces of the game and for the 
  # dark and light squares of the chessboard
	def chessboard_color_code(square_color, piece_color)
		square_color_code = { light: "44", dark: "40" }
		piece_color_code  = { white: "37", black: "36", clear: "32" }
		"1;#{ square_color_code[square_color] };#{ piece_color_code[piece_color] }"
	end

end
