# Class to define the properties and movement of a Chess Piece
class Piece
  DIR_CHANGE = { north: [-1, 0], ne: [-1, 1], east: [0,  1], se: [1,   1],
                 south: [ 1, 0], sw: [1, -1], west: [0, -1], nw: [-1, -1] }

  attr_accessor :color, :position, :type, :chessboard

  # Create a new kind of chess piece based on provided values
  def self.create(color, position, type, chessboard)
    position = position.dup
    case type
    when :king   then King.new(color, position, chessboard)
    when :queen  then Queen.new(color, position, chessboard)
    when :bishop then Bishop.new(color, position, chessboard)
    when :rook   then Rook.new(color, position, chessboard)
    when :knight then Knight.new(color, position, chessboard)
    when :pawn   then Pawn.new(color, position, chessboard)
    else Piece.new(:clear)
    end
  end
  
  def initialize(color = nil, position = nil, type = nil, chessboard = nil)
    @color = color
    @position = position
    @type = type
    @chessboard = chessboard
  end

  # String representation of a chess piece
  def to_s
    "Type: #{@type.to_s.upcase}, Color: #{@color}, Position: #{@position}"
  end

  # Gives all the positions a piece can legally move to
  def move_positions
    from = [@position[0], @position[1]]
    possible_positions.select do |position|
      not_check_causing_move?(from, position)
    end
  end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
  private

  # Determines if a move won't place or leave the player's King in check
  def not_check_causing_move?(from, to)
    en_passant_move = self.instance_of?(Pawn) && (to == @chessboard.en_passant_position)
    to_piece, en_passant_piece = temp_move(from, to, en_passant_move)

    caused_check = @chessboard.check?(@color)
    undo_temp_move(from, to, to_piece, en_passant_piece, en_passant_move)
    !caused_check
  end

  # Temporarily execute a move and return the piece captured by the move 
  # (if any). This method is used to check whether the move places the 
  # player's King in check
  def temp_move(from, to, en_passant_move)
    en_passant_piece = nil
    if en_passant_move
      en_passant_piece = @chessboard.move_piece(to, position_en_passant_captures)
    end
    to_piece = @chessboard.move_piece(from, to) 
    [to_piece, en_passant_piece]  
  end

  # Undo a temporary move and replace pieces captured by temporary move
  def undo_temp_move(from, to, to_piece, en_passant_piece, en_passant_move)
    @chessboard.move_piece(to, from)
    @chessboard.set_square(to, to_piece)
    if en_passant_move
      @chessboard.set_square(position_en_passant_captures, en_passant_piece)
    end
  end

  # Determine the position of the piece that would be captured by an en_passant move
  def position_en_passant_captures
    en_passant_capture_row = (@chessboard.en_passant_position[0] == 2) ? 3 : 4
    [en_passant_capture_row, @chessboard.en_passant_position[1]]
  end

  # Determine the positions that can be moved to in one step in various directions
  def move_once_towards(directions)
    piece_colors = @chessboard.get_piece_colors

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

  # Determine the positions that can be moved to in multiple steps in various directions
  def positions_towards(directions)
    piece_colors = @chessboard.get_piece_colors

    positions = []
    directions.each do |direction|
      next_position = add_positions(@position, DIR_CHANGE[direction])
      while board_position?(next_position)
        case piece_colors[next_position[0]][next_position[1]]
        when :clear then positions << next_position # no piece
        when @color then break                      # player's piece
        else positions << next_position; break      # opponent's piece
        end
        next_position = add_positions(next_position, DIR_CHANGE[direction])
      end
    end
    positions
  end

  # Determine if a given position is valid on a chessboard
  def board_position?(position)
    position[0].between?(0, Chess::SIZE - 1) && position[1].between?(0, Chess::SIZE - 1)
  end

  # Determine position from addition of the rows and columns of two positions
  def add_positions(position1, position2)
    [position1[0] + position2[0], position1[1] + position2[1]]
  end

  # Determine the color of the opponent's pieces
  def other_piece
    @color == :white ? :black : :white
  end
end
