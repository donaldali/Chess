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

  def initialize
  	@squares = generate_squares
  	set_squares_color_position
  	reset_square_pieces

  	@en_passant_position = nil
  	@no_capture_or_pawn_moves = 0
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

  def set_square(row, col, piece)
  	piece.position = [row, col]
  	@squares[row][col].piece = piece
  end

  def clear_square(row, col)
  	piece = Piece.new(:clear)
  	@squares[row][col].piece = piece
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

  def positions_attacked_by(player)
  	attacked = []
  	player_pieces(player).each do |piece|
  		attacked.concat(piece.possible_positions)
  	end
  	attacked.uniq
  end

  def square_at(position)
  	squares[position[0]][position[1]]
  end

  def piece_at(position)
  	squares[position[0]][position[1]].piece
  end

  def king_position(player)
    player_pieces(player).find{ |piece| piece.type == :king }.position
  end

  def check?(player)
    attacked_positions = positions_attacked_by(Chess.other_player(player))
    attacked_positions.include?(king_position(player))    
  end


	def display_board
		board_str = "\t  a  b  c  d  e  f  g  h \n\t"
		ranks = [8, 7, 6, 5, 4, 3, 2, 1]
		@squares.each_with_index do |row, row_index|
			board_str += "#{ranks[row_index]}"
			row.each do |square|
				board_str += colorize(" #{PIECES[square.piece.color].fetch(square.piece.type, ' ')} ",
					                    square_color_code(square.color, square.piece.color))
			end
			board_str += " #{ranks[row_index]}\n\t"
		end
		board_str += "  a  b  c  d  e  f  g  h \n"
		display_message board_str
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

	def display_message message 
		puts message	
	end

	# def print_message message 
	# 	print message	
	# end

end

# cb = Chessboard.new
# pieces = cb.player_pieces(:white)
# p pieces.map{|p| p.color }
# p pieces.map{|p| p.position }
# p pieces.map{|p| p.type }
# cb.display_board
# p cb
# p cb.squares[1][0].piece


# # print cb.display_board
# # puts
# puts cb.color("You are in check", :yellow)
# puts cb.color("Checkmate", :red)
# puts cb.color("Game Over", :flip)
