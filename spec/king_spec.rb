#
require_relative '../lib/chess/king'
require_relative '../lib/chess/chessboard'

describe King do 
	let(:piece_colors) {
	   [ [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:white, :black, :white, :white, :white, :white, :white, :white],
	     [:white, :clear, :clear, :clear, :white, :clear, :clear, :white] ]
		}
	let(:chessboard) { Chessboard.new }
	let(:king) { chessboard.squares[7][4].piece }
	
	before(:each) do
		# allow(chessboard).to receive(:get_piece_colors).and_return(piece_colors)
		chessboard.clear_square(7, 1)
		chessboard.clear_square(7, 2)
		chessboard.clear_square(7, 3)
		chessboard.clear_square(7, 5)
		chessboard.clear_square(7, 6)
	end

	describe '#possible_positions' do
		it 'steps to empty and open squares only' do
			chessboard.set_square(6, 0, king)
			chessboard.set_square(6, 1, Rook.new(:black, [6, 1], chessboard))
			expect(king.possible_positions).to match_array([[5, 0], [5, 1], [6, 1], [7, 1]])
	  end

	  it 'prevents castling when a piece is between king and rook' do 
	  	chessboard.set_square(7, 1, Knight.new(:white, [7, 1], chessboard))
	  	expect(king.possible_positions).to match_array([[7, 3], [7, 5], [7, 6]])
	  end

	  context 'when no piece between king and rook' do
	    it 'allows castling when appropriate' do
	    	chessboard.set_square(6, 1, Rook.new(:black, [6, 1], chessboard))
	    	expect(king.possible_positions).to match_array([[7, 2], [7, 3], [7, 5], [7, 6]])
	    end
	    it 'prevents castling when transit square under attack' do
	    	chessboard.set_square(6, 1, Bishop.new(:black, [6, 1], chessboard))
	    	expect(king.possible_positions).to match_array([[7, 3], [7, 5], [7, 6]])
	    end
	    it 'prevents castling when rook has moved' do
	    	chessboard.set_square(6, 1, Rook.new(:black, [6, 1], chessboard))
	    	chessboard.piece_at([7, 7]).moved = true
	    	expect(king.possible_positions).to match_array([[7, 2], [7, 3], [7, 5]])
	    end
	    it 'prevents castling when king has moved' do
	    	king.moved = true
	    	chessboard.set_square(6, 1, Rook.new(:black, [6, 1], chessboard))
	    	expect(king.possible_positions).to match_array([[7, 3], [7, 5]])
	    end
	  end

	end
end
