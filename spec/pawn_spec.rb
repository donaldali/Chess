require 'spec_helper'

describe Pawn do 
	let(:piece_colors) {
	   [ [:black, :black, :black, :clear, :black, :black, :black, :black],
		   [:black, :black, :black, :clear, :black, :clear, :black, :black],
		   [:clear, :black, :clear, :clear, :clear, :clear, :white, :white],
  	   [:clear, :clear, :clear, :clear, :clear, :black, :white, :clear],
	  	 [:clear, :clear, :white, :clear, :black, :clear, :clear, :clear],
		   [:clear, :black, :clear, :white, :clear, :clear, :clear, :clear],
		   [:white, :white, :white, :clear, :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white, :white, :white] ]
		}
	let(:chessboard) { Chessboard.new }
	let(:white_pawn) { chessboard.piece_at([6, 0]) }
	let(:black_pawn) { chessboard.piece_at([1, 0]) }

	before(:each) do
		allow(chessboard).to receive(:get_piece_colors).and_return(piece_colors)
	end

	describe '#possible_positions' do
		it 'can take one or two steps on first move' do
			chessboard.set_square([6, 0], white_pawn)
			expect(white_pawn.possible_positions).to match_array([[5, 0], [4, 0], [5, 1]])
	  end
	  it 'can take only one step after first move' do
			chessboard.set_square([4, 4], black_pawn)
			black_pawn.moved = true
			expect(black_pawn.possible_positions).to match_array([[5, 4], [5, 3]])
	  end
	  it 'includes en passant' do
			chessboard.set_square([3, 6], white_pawn)
			chessboard.en_passant_position = [2, 5]
			white_pawn.moved = true
			expect(white_pawn.possible_positions).to match_array([[2, 5]])
	  end
	end
end
