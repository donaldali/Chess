require_relative 'piece'
require_relative 'king'
require_relative 'queen'
require_relative 'bishop'
require_relative 'rook'
require_relative 'knight'
require_relative 'pawn'
require_relative 'chess_module'
include Chess

#
class Chessboard


	Square = Struct.new(:color, :position, :piece)

	SIZE = Chess::SIZE
	PIECES = { white: { king:   "\u2654", queen:  "\u2655", rook: "\u2656",
	                    bishop: "\u2657", knight: "\u2658", pawn: "\u2659" },
	           black: { king:   "\u265a", queen:  "\u265b", rook: "\u265c",
	                    bishop: "\u265d", knight: "\u265e", pawn: "\u265f" },
	           clear: { } }

  attr_accessor :squares, :en_passant_position, :no_capture_or_pawn_moves

  def initialize(players = {white: "White Player", black: "Black Player"})
  	@squares = generate_squares
  	set_squares_color_position
  	reset_square_pieces

  	@en_passant_position = nil
  	@no_capture_or_pawn_moves = 0
    @players = players
  end

  def generate_squares
  	squares = []
  	SIZE.times do 
  		new_row = []
  		SIZE.times { new_row << Square.new }
  		squares << new_row
  	end
  	squares
  end

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

  def reset_square_pieces
  	set_end_rows
  	set_pawn_rows
  	set_blank_rows
  end

  def set_end_rows
  	set_an_end_row(:black, 0, [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook])
  	set_an_end_row(:white, 7, [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook])
  end

  def set_an_end_row(piece_color, row, piece_types)
  	(0..SIZE - 1).each do |col|
  		piece = Piece.create(piece_color, [row, col], piece_types[col], self)
  		@squares[row][col].piece = piece
  	end
  end

  def set_pawn_rows
  	set_a_pawn_row(:black, 1)
  	set_a_pawn_row(:white, 6)
  end

  def set_a_pawn_row(piece_color, row)
  	(0..SIZE - 1).each do |col|
  		piece = Piece.create(piece_color, [row, col], :pawn, self)
  		@squares[row][col].piece = piece
  	end
  end

  def set_blank_rows
  	(2..5).each do |row|
  		set_a_blank_row(row)
  	end
  end

  def set_a_blank_row(row)
  	(0..SIZE - 1).each do |col|
  		piece = Piece.new(:clear)
  		@squares[row][col].piece = piece
  	end
  end

  def set_square(position, piece)
  	piece.position = [position[0], position[1]]
  	@squares[position[0]][position[1]].piece = piece
  end

  def clear_square(position)
  	piece = Piece.new(:clear)
  	@squares[position[0]][position[1]].piece = piece
  end

  def get_piece_colors
  	@squares.map do |row|
  		row.map { |square| square.piece.color }
  	end
  end

  def player_pieces(player)
  	@squares.map do |row|
  		row.map { |square| square.piece }
  	end.flatten.select { |piece| piece.color == player }
  end

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

  def square_at(position)
  	@squares[position[0]][position[1]]
  end

  def piece_at(position)
  	square_at(position).piece
  end

  def king_position(player)
    player_pieces(player).find{ |piece| piece.type == :king }.position
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

  # Determine if a stalemate condition occurs
  def stalemate?(player)
    no_valid_move?(player) && !check?(player)
  end

  # Determine if a player has no valid move
  def no_valid_move?(player)
    player_pieces(player).all? { |piece| piece.move_positions.empty? }
  end

  def checkmate_impossible?
    black_type_count = type_count(:black)
    white_type_count = type_count(:white)
    black_count = black_type_count.values.reduce(:+)
    white_count = white_type_count.values.reduce(:+)
    return false if black_type_count[:other] > 0 || white_type_count[:other] > 0
    return false if black_type_count[:knight] + white_type_count[:knight] > 1

    if black_count == 1 && white_count == 1 # King vs King
      return true
    elsif (black_count == 1 && white_count == 2) || (white_count == 1 && black_count == 2)
      return true
    else
      return all_bishops_on_same_square_color?
    end
  end

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

  def board_state
    pieces = []
    @squares.each do |row|
      row.each do |square|
        unless square.piece.color == :clear
          piece = square.piece
          pieces << [piece.color, piece.position, piece.type]
        end
      end
    end
    [pieces, @en_passant_position, get_castle_direction]    
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

  # Move the piece and return the piece that was at the position moved to
  def move_piece(from, to)
    to_piece = piece_at(to)
    set_square(to, piece_at(from))
    clear_square(from)
    to_piece
  end

  def move(from, to)
    to_piece = move_piece(from, to)
    update_moved(to)
    return if en_passant_capture(to)

    set_en_passant_position(from, to)
    update_no_capture_or_pawn_moves(to_piece, to)
    handle_promotion(to)
    castling_move(from, to)
  end

  def castling_move(from, to)
    move_col_change = subtract_positions(from, to)[1].abs
    if (piece_at(to).type == :king && move_col_change == 2)
      rook_from_col, rook_to_col = (to[1] == 2) ? [0, 3] : [7, 5]
      move_piece([to[0], rook_from_col], [to[0], rook_to_col])
      Chess.display_message "#{@players[piece_at(to).color]} just performed a castling move"
    end
  end

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

  def get_new_piece_type player
    options = %w(Queen Bishop Knight Rook)
    options_title = "New Piece Type"
    prompt = "please choose the piece that your pawn will be promoted to"
    Chess.display_message "#{@players[player]}, " + prompt

    convert_piece_type_choice Chess.get_option_choice(options, options_title)
  end

  def convert_piece_type_choice choice 
    case choice
    when 1 then return :queen
    when 2 then return :bishop
    when 3 then return :knight
    when 4 then return :rook
    end
  end

  def update_no_capture_or_pawn_moves(to_piece, to)
    if (to_piece.color != :clear || piece_at(to).type == :pawn)
      @no_capture_or_pawn_moves = 0
    else
      @no_capture_or_pawn_moves += 1
    end    
  end

  def set_en_passant_position(from, to)
    move_row_change = subtract_positions(from, to)[0].abs
    if (piece_at(to).type == :pawn && move_row_change == 2)
      en_passant_position_row = (to[0] == 3) ? 2 : 5
      @en_passant_position = [en_passant_position_row, to[1]]
    else
      @en_passant_position = nil
    end
  end

  def update_moved position
    moved_piece = piece_at(position)
    case moved_piece.type
    when :king, :rook, :pawn then moved_piece.moved = true
    end    
  end

  def en_passant_capture(to)
    return unless (to == @en_passant_position && piece_at(to).type == :pawn)

    en_passant_capture_row = (to[0] == 2) ? 3 : 4
    en_passant_capture_position = [en_passant_capture_row, to[1]]

    clear_square(en_passant_capture_position)
    Chess.display_message "#{@players[piece_at(to).color]} just captured en passant"
    @en_passant_position = nil
    @no_capture_or_pawn_moves = 0
  end

  def clear_position?(position)
    piece_at(position).color == :clear
  end

  # Determine position from subtraction of the rows and columns of two positions
  def subtract_positions(position1, position2)
    [position1[0] - position2[0], position1[1] - position2[1]]
  end


	def display_board(player = :white)
		board_str = "\t  a  b  c  d  e  f  g  h  \n\t"
		ranks = [8, 7, 6, 5, 4, 3, 2, 1]
		@squares.each_with_index do |row, row_index|
			board_str += "#{ranks[row_index]}"
			row.each do |square|
				board_str += colorize(" #{PIECES[square.piece.color].fetch(square.piece.type, 'X')} ",
					                    square_color_code(square.color, square.piece.color))
			end
			board_str += " #{ranks[row_index]}\n\t"
		end
		board_str += "  a  b  c  d  e  f  g  h  \n"

		Chess.display_message player_view(board_str, player)
  end

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

	def square_color_code(square_color, piece_color)
		background = { light: "44", dark: "40" }
		foreground = { white: "37", black: "36", clear: "32" }
		"1;#{ background[square_color] };#{ foreground[piece_color] }"
	end

	# Color is expected as a symbol. Eg :yellow or :red
	def color(text, color)
		case color
		when :red then colorize(text, "31")
		when :yellow then colorize(text, "33")
		when :green then colorize(text, "32")
		when :flip then colorize(text, "7")
		else colorize(text, "0")
		end
	end

	# Color code is expected. Eg "1;34;44"
	def colorize(text, color_code)
		"\033[#{color_code}m#{text}\033[0m"
	end

	# def display_message message 
	# 	puts message	
	# end

	# def print_message message 
	# 	print message	
	# end
  def clear_board
    clear_board = Chessboard.new
    (0..Chess::SIZE - 1).each do |row|
      (0..Chess::SIZE - 1).each do |col|
        clear_board.clear_square([row, col])
      end
    end
    clear_board
  end
end


chessboard = Chessboard.new.clear_board
chessboard.set_square([1, 2], King.new(:black, [1, 2], chessboard))
chessboard.set_square([5, 6], King.new(:white, [5, 6], chessboard))
p chessboard.board_state
# cb = Chessboard.new
# cb.move_piece([6,1],[5,1])
# cb.display_board
# puts "====================================================="
# cb.display_board :black
# pieces = cb.player_pieces(:white)
# p pieces.map{|p| p.color }
# p pieces.map{|p| p.position }
# p pieces.map{|p| p.type }
# p cb
# p cb.squares[1][0].piece


# # print cb.display_board
# # puts
# puts cb.color("You are in check", :yellow)
# puts cb.color("Checkmate", :red)
# puts cb.color("Game Over", :flip)
