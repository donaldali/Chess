require 'spec_helper'

describe Bishop do 
	let(:piece_colors) {
	   [ [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:black, :black, :black, :black, :black, :black, :black, :black],
  	   [:clear, :black, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:white, :white, :white, :white, :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white, :clear, :white] ]
		}
	let(:chessboard) { Chessboard.new }
	let(:bishop) { chessboard.piece_at([7, 5]) }

	describe '#possible_positions' do
		it 'stops before board boundary and friendly piece, but at enemy piece' do
			allow(chessboard).to receive(:get_piece_colors).and_return(piece_colors)
			chessboard.set_square([6, 5], bishop)
			expect(bishop.possible_positions).to match_array([[7, 6], [5, 6], [4, 7], [5, 4],
				                                                [4, 3], [3, 2], [2, 1]])
	  end
	end
end
